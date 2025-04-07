import { z } from "zod"

export const registerSchema = z.object({
  username: z.string().min(3).max(30),
  email: z.string().email(),
  password: z.string().min(8),
  gender: z.enum(['male', 'female', 'others']).optional(),
})

export const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
})