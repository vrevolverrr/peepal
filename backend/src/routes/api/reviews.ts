import { Hono } from 'hono'
import { db, minio } from '../../app'
import { reviews, toilets, users } from '../../db/schema'
import { eq, desc, asc, getTableColumns, sql } from 'drizzle-orm'
import { validator } from '../../middleware/validator'
import { editReviewSchema, fetchReviewsSchema, postReviewSchema, reviewIdSchema } from '../../validators/api/reviews'
import { toiletIdParamSchema } from '../../validators/api/toilets'

/**
 * The Hono instance for the reviews API.
 */
const reviewsApi = new Hono()

/**
 * Error handler for the reviews API.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {Error} err - The error object.
 * 
 * @returns {Promise<{ error: string }>} - The error message.
 */
reviewsApi.onError((err, c) => {
  const logger = c.get('logger')
  logger.error(`Error in reviews API ${err}`)
  return c.json({ error: err.message }, 500)
})

/**
 * GET /api/reviews - Health Check
 * 
 * @param {Context} c - The Hono Context object.
 * 
 * @returns {Promise<{ message: string }>} - The health check message.
 */
reviewsApi.get('/', async (c) => {
  return c.json({ message: 'Reviews Endpoint Health Check'}, 200)
})

/**
 * GET /api/reviews/toilet/:toiletId?sort=date|rating&order=asc|desc&offset=0
 * 
 * @param {Context} c - The Hono Context object.
 * @param {ToiletIdParamSchema} toiletId - The ID of the toilet.
 * @param {FetchReviewsSchema} offset - The offset for pagination.
 * @param {FetchReviewsSchema} sort - The field to sort the reviews by.
 * 
 * @returns {Promise<{ reviews: Review[] }>} - The reviews for the specified toilet.
 */
reviewsApi.get('/toilet/:toiletId', 
  validator('param', toiletIdParamSchema), validator('json', fetchReviewsSchema), async (c) => {
  const logger = c.get('logger')
  logger.error(c.req.param())
  const { toiletId } = c.req.valid('param')
  const { offset, sort, order } = c.req.valid('json')

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
    .select({
      ...getTableColumns(reviews),
      username: users.username
    })
    .from(reviews)
    .innerJoin(users, eq(reviews.userId, users.id))
    .where(eq(reviews.toiletId, toiletId))
    .orderBy(orderBy)
    .offset(offset || 0)
    .limit(10)

  logger.info(`Reviews fetched for toilet ${toiletId}`)
  return c.json({ reviews: result }, 200)
})

/**
 * POST /api/reviews/create - Post a review
 * 
 * @param {Context} c - The Hono Context object.
 * @param {PostReviewSchema} toiletId - The ID of the toilet to post the review for.
 * @param {PostReviewSchema} rating - The rating of the review.
 * @param {PostReviewSchema} reviewText - The text of the review.
 * @param {PostReviewSchema} imageToken - The image token of the review, if any.
 * 
 * @returns {Promise<{ review: Review }>} - The created review.
 */
reviewsApi.post('/create', validator('json', postReviewSchema), async (c) => {
  const logger = c.get('logger')
  const userId = c.get('user').id

  const { toiletId, rating, reviewText, imageToken } = c.req.valid('json')

  const [ review ] = await db
    .insert(reviews)
    .values({
      toiletId,
      userId,
      rating,
      reviewText,
      imageToken,
      createdAt: new Date(),
    }).returning()

    const [ updatedReview ] = await db
      .select({
        ...getTableColumns(reviews),
        username: users.username
      })
      .from(reviews)
      .innerJoin(users, eq(reviews.userId, users.id))
      .where(eq(reviews.id, review.id))

    await db.update(toilets)
      .set({
        rating: sql`(${toilets.rating} + ${rating}) / 2`,
      })
      .where(eq(toilets.id, toiletId))

  logger.info('Review created', review.id)
  return c.json({ review: updatedReview }, 201)
})

/**
 * PATCH /api/reviews/edit - Edit review
 * 
 * @param {Context} c - The Hono Context object.
 * @param {ReviewIdSchema} reviewId - The ID of the review to edit.
 * @param {EditReviewSchema} rating - The new rating of the review.
 * @param {EditReviewSchema} reviewText - The new text of the review.
 * @param {EditReviewSchema} imageToken - The new image token of the review, if any.
 * 
 * @returns {Promise<{ review: Review }>} - The updated review. 
 */
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

/**
 * POST /api/reviews/report/:reviewId - Report a review.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {ReviewIdSchema} reviewId - The ID of the review to report.
 * 
 * @returns {Promise<{ message: string, deleted: boolean }>} - The result of the report.
 */
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

/**
 * DELETE /api/reviews/delete/:reviewId - Delete a review.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {ReviewIdSchema} reviewId - The ID of the review to delete.
 * 
 * @returns {Promise<{ message: string }>} - The result of the deletion.
 */
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