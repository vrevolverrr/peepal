import { z } from 'zod'

export const imageUploadSchema = z.object({
  type: z.enum(['toilet', 'review']),
  image: z.instanceof(File)
    .refine((file) => file.type.startsWith('image/'), { message: 'Invalid file type' })
    .refine((file) => file.size <= 5 * 1024 * 1024, { message: 'File size exceeds 5MB' })
})

export const imageTokenSchema = z.object({
  token: z.string(),
})