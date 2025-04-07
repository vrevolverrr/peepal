import { z } from 'zod'

export const updateUserSchema = z.object({
  username: z.string().min(3).max(30).optional(),
  email: z.string().email().optional(),
  gender: z.enum(['male', 'female', 'others']).optional(),
})