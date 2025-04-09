import { Hono } from 'hono'
import { db } from '../../app'
import { reviews } from '../../db/schema'
import { sql, eq, desc } from 'drizzle-orm'
import { validator } from '../../lib/validator'
import { createReviewSchema, updateReviewSchema, deleteReviewSchema, reportReviewSchema, fetchReviewsSchema } from '../../validators/api/reviews'

const reviewApi = new Hono()

reviewApi.onError((err, c) => {
  const logger = c.get('logger')
  logger.error('Error in reviews API', err)
  return c.json({ error: err.message }, 500)
})

// GET /api/reviews - Health Check
reviewApi.get('/', async (c) => {
  const logger = c.get('logger')
  return c.json({ message: 'Reviews Endpoint Health Check'}, 200)
})

// POST /api/reviews - Create a review
reviewApi.post('/', validator('json', createReviewSchema), async (c) => {
  const logger = c.get('logger')
  const userId = c.get('user').id

  const { toiletId, rating, reviewText, imageUrl } = c.req.valid('json')

  const [review] = await db
    .insert(reviews)
    .values({
      toiletId,
      userId,
      rating,
      reviewText,
      imageUrl,
      createdAt: new Date(),
    })
    .returning()

  logger.info('Review created', review.id)
  return c.json({ review }, 201)
})

// GET /api/reviews/toilet/:toilet_id?sort=date|rating|report
reviewApi.get('/toilet/:toilet_id', validator('query', fetchReviewsSchema), async (c) => {
  const logger = c.get('logger')
  const { toiletId, sort } = c.req.valid('query')

  let orderBy
  if (sort === 'rating') orderBy = desc(reviews.rating)
  else if (sort === 'report') orderBy = desc(reviews.reportCount)
  else orderBy = desc(reviews.createdAt)

  const result = await db
    .select()
    .from(reviews)
    .where(eq(reviews.toiletId, toiletId))
    .orderBy(orderBy)
    .limit(10)

  logger.info(`Reviews fetched for toilet ${toiletId}`)
  return c.json({ reviews: result }, 200)
})

// PATCH /api/reviews/:id - Edit review
reviewApi.patch('/:id', validator('json', updateReviewSchema), async (c) => {
  const logger = c.get('logger')
  const reviewId = Number(c.req.param('id'))

  const body = c.req.valid('json')

  // check if review exists
  const [existing] = await db.select().from(reviews).where(eq(reviews.id, reviewId))

  if (!existing) {
    logger.error(`Review not found with ID: ${reviewId}`)
    return c.json({ error: 'Review not found' }, 404)
  }

  const [updated] = await db
    .update(reviews)
    .set(body)
    .where(eq(reviews.id, reviewId))
    .returning()

  logger.info('Review updated', reviewId)
  return c.json({ review: updated }, 200)
})

// DELETE /api/reviews/:id - Delete review
reviewApi.delete('/:id', validator('json', deleteReviewSchema), async (c) => {
  const logger = c.get('logger')
  const reviewId = Number(c.req.param('id'))

  const [existing] = await db.select().from(reviews).where(eq(reviews.id, reviewId))

  if (!existing) {
    logger.error(`Review not found with ID: ${reviewId}`)
    return c.json({ error: 'Review not found' }, 404)
  }

  await db.delete(reviews).where(eq(reviews.id, reviewId))
  logger.info(`Review ${reviewId} deleted by user ${c.get('user').id}`)
  return c.json({ message: 'Review deleted successfully' }, 200)
})

// POST /api/reviews/:id/report - Report a review
reviewApi.post('/:id/report', validator('json', reportReviewSchema), async (c) => {
  const logger = c.get('logger')
  const reviewId = Number(c.req.param('id'))

  const [review] = await db
    .select({ reportCount: reviews.reportCount })
    .from(reviews)
    .where(eq(reviews.id, reviewId))

  if (!review) {
    logger.error(`Review not found with ID: ${reviewId}`)
    return c.json({ error: 'Review not found' }, 404)
  }

  const newCount = (review.reportCount ?? 0) + 1

  if (newCount >= 3) {
    await db.delete(reviews).where(eq(reviews.id, reviewId))
    logger.info(`Review ${reviewId} deleted after reaching ${newCount} reports`)
    return c.json({ message: 'Review reported and deleted after reaching threshold' }, 200)
  }

  await db.update(reviews)
    .set({
      reportCount: sql`${reviews.reportCount} + 1`,
    })
    .where(eq(reviews.id, reviewId))

  logger.info(`Review ${reviewId} reported (${newCount} reports)`)
  return c.json({ message: 'Review reported' }, 200)
})

// Export the router
export default reviewApi