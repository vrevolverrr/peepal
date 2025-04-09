import { Hono } from 'hono'
import { db } from '../../app'
import { reviews } from '../../db/schema'
import { sql, eq, desc, asc } from 'drizzle-orm'
import { validator } from '../../middleware/validator'
import { editReviewSchema, fetchReviewsSchema, postReviewSchema, reviewIdSchema } from '../../validators/api/reviews'

const reviewApi = new Hono()

reviewApi.onError((err, c) => {
  const logger = c.get('logger')
  logger.error(`Error in reviews API ${err}`)
  return c.json({ error: err.message }, 500)
})

// GET /api/reviews - Health Check
reviewApi.get('/', async (c) => {
  return c.json({ message: 'Reviews Endpoint Health Check'}, 200)
})

// POST /api/reviews/create - Post a review
reviewApi.post('/create', validator('json', postReviewSchema), async (c) => {
  const logger = c.get('logger')
  const userId = c.get('user').id

  const { toiletId, rating, reviewText, imageToken } = c.req.valid('json')

  const [review] = await db
    .insert(reviews)
    .values({
      toiletId,
      userId,
      rating,
      reviewText,
      imageToken,
      createdAt: new Date(),
    })
    .returning()

  logger.info('Review created', review.id)
  return c.json({ review: review }, 201)
})

// GET /api/reviews/toilet/:toilet_id?sort=date|rating&order=asc|desc&offset=0
reviewApi.get('/toilet/:toilet_id', validator('query', fetchReviewsSchema), async (c) => {
  const logger = c.get('logger')
  const { toiletId, offset, sort, order } = c.req.valid('query')

  let orderBy: any  
  if (sort === 'rating') orderBy = order === 'asc' ? asc(reviews.rating) : desc(reviews.rating)
  else orderBy = order === 'asc' ? asc(reviews.createdAt) : desc(reviews.createdAt)

  const result = await db
    .select()
    .from(reviews)
    .where(eq(reviews.toiletId, toiletId))
    .orderBy(orderBy)
    .offset(offset || 0)
    .limit(10)

  logger.info(`Reviews fetched for toilet ${toiletId}`)
  return c.json({ reviews: result }, 200)
})

// PATCH /api/reviews/:id - Edit review
reviewApi.patch('/edit', validator('json', editReviewSchema), async (c) => {
  const logger = c.get('logger')
  const { reviewId, rating, reviewText, imageToken } = c.req.valid('json')

  // Check if at least one field is provided
  if (rating === undefined && reviewText === undefined && imageToken === undefined) {
    return c.json({ error: 'No fields to update' }, 400)
  }

  // Check if review exists
  const [ existing ] = await db.select().from(reviews).where(eq(reviews.id, reviewId))

  if (!existing) {
    logger.error(`Review not found with ID: ${reviewId}`)
    return c.json({ error: 'Review not found' }, 400)
  }

  if (existing.imageToken) {
    // Delete image from S3 bucket
  }

  const [updated] = await db
    .update(reviews)
    .set({ rating, reviewText, imageToken })
    .where(eq(reviews.id, reviewId))
    .returning()

  logger.info('Review updated', reviewId)
  return c.json({ review: updated }, 200)
})

// DELETE /api/reviews/delete/:reviewId - Delete review
reviewApi.delete('/delete/:reviewId', validator('query', reviewIdSchema), async (c) => {
  const logger = c.get('logger')
  const { reviewId } = c.req.valid('query')

  const [existing] = await db.select().from(reviews).where(eq(reviews.id, reviewId))

  if (!existing) {
    logger.error(`Review not found with ID: ${reviewId}`)
    return c.json({ error: 'Review not found' }, 404)
  }

  await db.delete(reviews).where(eq(reviews.id, reviewId))
  logger.info(`Review ${reviewId} deleted by user ${c.get('user').id}`)
  return c.json({ message: 'Review deleted successfully' }, 200)
})

// POST /api/reviews/report/:reviewId - Report a review
reviewApi.post('/report/:reviewId', validator('query', reviewIdSchema), async (c) => {
  const logger = c.get('logger')
  const { reviewId } = c.req.valid('query')

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