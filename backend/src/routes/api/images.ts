import { Hono } from 'hono'
import { db, minio } from '../../app'
import { validator } from '../../middleware/validator'
import { imageUploadSchema, imageTokenSchema } from '../../validators/api/images'
import { nanoid } from 'nanoid'
import { images } from '../../db/schema/images'
import { eq } from 'drizzle-orm'

/**
 * The Hono instance for the images API.
 */
const imageApi = new Hono()

/**
 * Error handler for the images API.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {Error} err - The error object.
 * 
 * @returns {Promise<{ error: string }>} - The error message.
 */
imageApi.onError((err, c) => {
  const logger = c.get('logger')
  logger.error(`Error in image API: ${err}`)
  return c.json({ error: err.message }, 500)
})

/**
 * GET /api/images/get/:token - Get an image
 * 
 * @param {Context} c - The Hono Context object.
 * @param {string} token - The image token.
 * 
 * @returns {Promise<{ url: string }>} - The image URL.
 */
imageApi.get('/:token', validator('query', imageTokenSchema), async (c) => {
  const logger = c.get('logger')
  const { token } = c.req.valid('query')

  const objectName = (await db.select({
    filename: images.filename
  }).from(images).where(eq(images.token, token)).limit(1))[0]?.filename

  logger.info(`Image found in DB: ${objectName}`)

  if (!objectName) {
    logger.error(`Image not found in DB for token: ${token}`)
    return c.json({ error: 'Image not found' }, 400)
  }

  try {
    await minio.statObject(process.env.S3_BUCKET || '', objectName)
  } catch {
    logger.error(`Image not found in S3 for token: ${token}`)
    return c.json({ error: 'Image not found' }, 400)
  }

  // Generate presigned URL for the image
  const url = await minio.presignedGetObject(
    process.env.S3_BUCKET || '',
    objectName,
    60 * 5 // URL expires in 5 minutes
  )

  logger.info('Image URL generated:', objectName)
  return c.json({ url }, 200)
})

/**
 * POST /api/images/upload - Upload an image
 * 
 * @param {Context} c - The Hono Context object.
 * @param {ImageUplaodSchema} type - The type of the image (toilet or review).
 * @param {ImageUploadSchema} image - The image to upload.
 * 
 * @returns {Promise<{ token: string }>} - The image token.
 */
imageApi.post('/upload', validator('form', imageUploadSchema), async (c) => {
  const logger = c.get('logger')
  const form = await c.req.parseBody()
  const image = form.image as File

  // Generate unique token for the image
  const token = nanoid()
  const extension = image.name.split('.').pop()
  const objectName = `${token}.${extension}`

  const buffer = await image.arrayBuffer()

  // Upload image to S3 bucket
  await minio.putObject(
    process.env.S3_BUCKET || '',
    objectName,
    Buffer.from(buffer),
    image.size,
    { 'Content-Type': image.type }
  )

  // Store image metadata in database
  await db.insert(images).values({
    token,
    type: form.type as string,
    userId: c.get('user').id,
    filename: objectName,
    uploadedAt: new Date()
  })

  logger.info(`Image uploaded: ${objectName}`)
  return c.json({ token }, 201)
})

export default imageApi