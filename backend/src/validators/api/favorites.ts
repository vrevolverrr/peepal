import { z } from 'zod'

export const addFavoriteSchema = z.object({
  toiletId: z.number()
})

export const deleteFavoriteSchema = z.object({
  toiletId: z.number()
})  