import { z } from 'zod'

export const imageUploadSchema = z.object({
  type: z.enum(['toilet', 'review']),
  image: z.any()
})

export const imageTokenSchema = z.object({
  token: z.string(),
})