import { z } from 'zod'

/**
 * The schema for the image upload endpoint.
 *
 * The image upload endpoint requires a form with two fields: type and image.
 * The type field should be one of 'toilet' or 'review', and the image field
 * should be a file.
 */
export const imageUploadSchema = z.object({
  type: z.enum(['toilet', 'review']),
  image: z.any()
})

/**
 * The schema for the image token endpoint.
 *
 * The image token endpoint requires a JSON object with one field: token.
 * The token field should be a string that represents a unique identifier
 * for the image.
 */
export const imageTokenSchema = z.object({
  token: z.string(),
})