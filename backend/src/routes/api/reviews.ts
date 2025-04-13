import { Hono } from 'hono'
import { db, minio } from '../../app'
import { reviews, toilets } from '../../db/schema'
import { eq, desc, asc } from 'drizzle-orm'
import { validator } from '../../middleware/validator'
import { editReviewSchema, fetchReviewsSchema, postReviewSchema, reviewIdSchema } from '../../validators/api/reviews'
import { toiletIdParamSchema } from '../../validators/api/toilets'

const reviewsApi = new Hono()

reviewsApi.onError((err, c) => {
  const logger = c.get('logger')
  logger.error(`Error in reviews API ${err}`)
  return c.json({ error: err.message }, 500)
})

// GET /api/reviews - Health Check
reviewsApi.get('/', async (c) => {
  return c.json({ message: 'Reviews Endpoint Health Check'}, 200)
})

// GET /api/reviews/toilet/:toiletId?sort=date|rating&order=asc|desc&offset=0
reviewsApi.get('/toilet/:toiletId', 
  validator('param', toiletIdParamSchema), validator('query', fetchReviewsSchema), async (c) => {
  const logger = c.get('logger')
  logger.error(c.req.param())
  const { toiletId } = c.req.valid('param')
  const { offset, sort, order } = c.req.valid('query')

  // First check if toilet exists
  const [ toilet ] = await db.select().from(toilets).where(eq(toilets.id, toiletId))

  if (!toilet) {
    logger.error(`Toilet not found with ID: ${toiletId}`)
    return c.json({ error: 'Toilet not found' }, 404)
  }

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

// POST /api/reviews/create - Post a review
reviewsApi.post('/create', validator('json', postReviewSchema), async (c) => {
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

// PATCH /api/reviews/edit - Edit review
reviewsApi.patch('/edit/:reviewId', 
  validator('param', reviewIdSchema), validator('json', editReviewSchema), async (c) => {
  const logger = c.get('logger')
  const { reviewId } = c.req.valid('param')
  const {  rating, reviewText, imageToken } = c.req.valid('json')

  // Check if at least one field is provided
  if (rating === undefined && reviewText === undefined && imageToken === undefined) {
    return c.json({ error: 'No fields to update' }, 400)
  }

  // Check if review exists
  const [ existing ] = await db.select().from(reviews).where(eq(reviews.id, reviewId))

  if (!existing) {
    logger.error(`Review not found with ID: ${reviewId}`)
    return c.json({ error: 'Review not found' }, 404)
  }

  if (existing.userId !== c.get('user').id) {
    logger.error(`User ${c.get('user').id} is not authorized to edit review ${reviewId}`)
    return c.json({ error: 'You are not authorized to edit this review' }, 403)
  }

  if (existing.imageToken && imageToken !== existing.imageToken) {
    // Delete existing image from S3 bucket
    await minio.removeObject(process.env.S3_BUCKET || '', existing.imageToken)
  }

  const [updated] = await db
    .update(reviews)
    .set({ rating, reviewText, imageToken })
    .where(eq(reviews.id, reviewId))
    .returning()

  logger.info('Review updated', reviewId)
  return c.json({ review: updated }, 200)
})

// POST /api/reviews/report/:reviewId - Report a review
reviewsApi.post('/report/:reviewId', validator('param', reviewIdSchema), async (c) => {
  const logger = c.get('logger')
  const { reviewId } = c.req.valid('param')

  const [existing] = await db.select().from(reviews).where(eq(reviews.id, reviewId))

  if (!existing) {
    logger.error(`Review not found with ID: ${reviewId}`)
    return c.json({ error: 'Review not found' }, 404)
  }

  const numReports = existing.reportCount || 0
  const updatedReportCount = numReports + 1

  if (updatedReportCount >= 3) {
    await db.delete(reviews).where(eq(reviews.id, reviewId))
    logger.info(`Review ${reviewId} deleted due to 3 reports`)
    return c.json({ message: 'Review reported and deleted after reaching threshold', deleted: true }, 200)
  }

  const [ updated ] = await db
    .update(reviews)
    .set({ reportCount: updatedReportCount })
    .where(eq(reviews.id, reviewId))
    .returning()

  logger.info(`Review ${reviewId} reported`)
  return c.json({ message: 'Review reported', deleted: false }, 200)
})

// DELETE /api/reviews/delete/:reviewId - Delete review
reviewsApi.delete('/delete/:reviewId', validator('param', reviewIdSchema), async (c) => {
  const logger = c.get('logger')
  const { reviewId } = c.req.valid('param')

  const [ existing ] = await db.select().from(reviews).where(eq(reviews.id, reviewId))

  if (!existing) {
    logger.error(`Review not found with ID: ${reviewId}`)
    return c.json({ error: 'Review not found' }, 404)
  }

  if (existing.userId != c.get('user').id) {
    logger.error(`User ${c.get('user').id} is not authorized to delete review ${reviewId}`)
    return c.json({ error: 'You are not authorized to delete this review' }, 403)
  }

  // Delete existing image from S3 bucket
  if (existing.imageToken) {
    await minio.removeObject(process.env.S3_BUCKET || '', existing.imageToken)
  }

  await db.delete(reviews).where(eq(reviews.id, reviewId))
  logger.info(`Review ${reviewId} deleted`)
  return c.json({ message: 'Review deleted' }, 200)
})

export default reviewsApi