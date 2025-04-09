import { z } from 'zod'

export const createReviewSchema = z.object({
    toiletId: z.number(),
    rating: z.number().int().min(1).max(5),
    reviewText: z.string().optional(),
    imageUrl: z.string().url().optional()
  })
  
  export const updateReviewSchema = z.object({
    rating: z.number().int().min(1).max(5).optional(),
    reviewText: z.string().optional(),
    imageUrl: z.string().url().optional()
  })
  
  export const deleteReviewSchema = z.object({
    reviewId: z.number()
  })
  
  export const reportReviewSchema = z.object({
    reviewId: z.number()
  })

  export const fetchReviewsSchema = z.object({
    toiletId: z.number(),
    sort: z.enum(['date', 'rating', 'report']).optional()
  })