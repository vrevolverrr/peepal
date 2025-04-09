import { z } from 'zod'

export const reviewIdSchema = z.object({
  reviewId: z.number()
})

export const postReviewSchema = z.object({
    toiletId: z.string(),
    rating: z.number().int().min(1).max(5),
    reviewText: z.string().optional(),
    imageToken: z.string().optional()
  })
  
export const editReviewSchema = z.object({
  reviewId: z.number(),
  rating: z.number().int().min(1).max(5).optional(),
  reviewText: z.string().optional(),
  imageToken: z.string().optional()
})

export const fetchReviewsSchema = z.object({
  toiletId: z.string(),
  offset: z.number().optional().default(0),
  sort: z.enum(['date', 'rating']).optional().default('date'),
  order: z.enum(['asc', 'desc']).optional().default('desc')
})