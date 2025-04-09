import { Hono } from 'hono'
import { db } from '../../app'
import { reviews } from '../../db/schema'
import { sql, eq, desc } from 'drizzle-orm'

const reviewApi = new Hono()

// Export the router
export default reviewApi

reviewApi.onError((err, c) => {
  const logger = c.get('logger')
  logger.error('Error in reviews API', err)

  return c.json({ error: err.message }, 500)
})

// POST /api/reviews - Create a review
reviewApi.post('/', async (c) => {
  // Verify auth token
  const user = c.get('user')
  if (!user) {
    return c.json({ error: 'Unauthorized' }, 401)
  }
  const logger = c.get('logger')
  const body = await c.req.json()

  const { toiletId, rating, reviewText, imageUrl } = body

  if (!toiletId || !rating || rating < 1 || rating > 5) {
    return c.json({ error: 'Invalid input' }, 400)
  }

  try {
    const [review] = await db
      .insert(reviews)
      .values({
        toiletId,
        userId: user.id,
        rating,
        reviewText,
        imageUrl,
        createdAt: new Date(),
      })
      .returning()

    logger.info('Review created', review.id)
    return c.json({ review }, 201)
  } catch (err) {
    logger.error('Error creating review', err)
    return c.json({ error: 'Internal server error' }, 500)
  }
})

// GET /api/reviews/toilet/:toilet_id?sort=date|rating|report
reviewApi.get('/toilet/:toilet_id', async (c) => {
  // Verify auth token
  const user = c.get('user')
  if (!user) {
    return c.json({ error: 'Unauthorized' }, 401)
  }
  const toiletId = Number(c.req.param('toilet_id'))
  if (isNaN(toiletId)) {
    return c.json({ error: 'Invalid toilet ID' }, 400)
  }
  const sort = c.req.query('sort') || 'date'
  const logger = c.get('logger')

  let orderBy
  if (sort === 'rating') orderBy = desc(reviews.rating)
  else if (sort === 'report') orderBy = desc(reviews.reportCount)
  else orderBy = desc(reviews.createdAt)

  try {
    const result = await db
      .select()
      .from(reviews)
      .where(eq(reviews.toiletId, toiletId))
      .orderBy(orderBy)

    return c.json({ reviews: result }, 200)
  } catch (err) {
    logger.error('Error fetching reviews', err)
    return c.json({ error: 'Failed to fetch reviews' }, 500)
  }
})

// PUT /api/reviews/:id - Edit review
reviewApi.put('/:id', async (c) => {
  // Verify auth token
  const user = c.get('user')
  if (!user) {
    return c.json({ error: 'Unauthorized' }, 401)
  }
  const reviewId = Number(c.req.param('id'))
  if (isNaN(reviewId)) {
    return c.json({ error: 'Invalid review ID' }, 400)
  }
  const body = await c.req.json()
  const logger = c.get('logger')

  try {
    const [existing] = await db.select().from(reviews).where(eq(reviews.id, reviewId))

    if (!existing) {
      return c.json({ error: 'Review not found' }, 404)
    }

    if (existing.userId !== user.id) {
      return c.json({ error: 'Not authorized' }, 403)
    }

    const updatedFields = {
      reviewText: body.reviewText ?? existing.reviewText,
      rating: body.rating ?? existing.rating,
      imageUrl: body.imageUrl ?? existing.imageUrl,
    }

    const [updated] = await db
      .update(reviews)
      .set(updatedFields)
      .where(eq(reviews.id, reviewId))
      .returning()

    logger.info('Review updated', reviewId)
    return c.json({ review: updated }, 200)
  } catch (err) {
    logger.error('Error updating review', err)
    return c.json({ error: 'Failed to update review' }, 500)
  }
})

// DELETE /api/reviews/:id - Delete review
reviewApi.delete('/:id', async (c) => {
  // Verify auth token
  const user = c.get('user')
  if (!user) {
    return c.json({ error: 'Unauthorized' }, 401)
  }
  const reviewId = Number(c.req.param('id'))
  if (isNaN(reviewId)) {
    return c.json({ error: 'Invalid review ID' }, 400)
  }
  const logger = c.get('logger')

  try {
    // Check if review exists and belongs to user
    const [existing] = await db.select().from(reviews).where(eq(reviews.id, reviewId))

    if (!existing) {
      return c.json({ error: 'Review not found' }, 404)
    }

    if (existing.userId !== user.id) {
      return c.json({ error: 'Not authorized' }, 403)
    }

    // Delete the review
    await db.delete(reviews).where(eq(reviews.id, reviewId))
    logger.info(`Review ${reviewId} deleted by user ${user.id}`)
    return c.json({ message: 'Review deleted successfully' }, 200)
  } catch (err) {
    logger.error('Error deleting review', err)
    return c.json({ error: 'Failed to delete review' }, 500)
  }
})

// POST /api/reviews/:id/report - Report a review
reviewApi.post('/:id/report', async (c) => {
  // Verify auth token
  const user = c.get('user')
  if (!user) {
    return c.json({ error: 'Unauthorized' }, 401)
  }
  const reviewId = Number(c.req.param('id'))
  if (isNaN(reviewId)) {
    return c.json({ error: 'Invalid review ID' }, 400)
  }
  const logger = c.get('logger')

  try {
    // Step 1: Fetch current report count
    const [review] = await db
      .select({ reportCount: reviews.reportCount })
      .from(reviews)
      .where(eq(reviews.id, reviewId))

    if (!review) {
      return c.json({ error: 'Review not found' }, 404)
    }

    const newCount = (review.reportCount ?? 0) + 1

    // Step 2: If count >= 5, delete it
    if (newCount >= 5) {
      await db.delete(reviews).where(eq(reviews.id, reviewId))
      logger.info(`Review ${reviewId} deleted after reaching ${newCount} reports`)
      return c.json({ message: 'Review reported and deleted after reaching threshold' }, 200)
    }

    // Step 3: Otherwise, increment report count
    await db.update(reviews)
      .set({
        reportCount: sql`${reviews.reportCount} + 1`,
      })
      .where(eq(reviews.id, reviewId))

    logger.info(`Review ${reviewId} reported (${newCount} reports)`)
    return c.json({ message: 'Review reported' }, 200)
  } catch (err) {
    logger.error('Error reporting review', err)
    return c.json({ error: 'Internal server error' }, 500)
  }
})