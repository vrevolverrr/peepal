import { z } from 'zod'

/**
 * The schema for the reviewId parameter in the reviews API.
 * The reviewId is required and must be a string that can be converted to a number.
 */
export const reviewIdSchema = z.object({
  reviewId: z.string().transform(Number)
})

/**
 * The schema for creating a new review. The toiletId is required as it is used to identify which toilet the review is for.
   * The rating is also required, and must be between 1 and 5. The reviewText is optional, and the imageToken is also optional.
   * If the imageToken is provided, it will be used to upload the image to Minio.
   */
export const postReviewSchema = z.object({
    toiletId: z.string(),
    rating: z.number().int().min(1).max(5),
    reviewText: z.string().optional(),
    imageToken: z.string().optional()
  })
  
  /**
   * The schema for the review edit endpoint.
   *
   * The review edit endpoint requires a JSON object with up to three fields:
   * - `rating`: The new rating of the review.
   * - `reviewText`: The new text of the review.
   * - `imageToken`: The new image token of the review.
   *
   * The `rating` field should be an integer between 1 and 5.
   * The `reviewText` field should be a string.
   * The `imageToken` field should be a string.
   *
   * The `optional` method is used to make all fields optional.
   * This means that the endpoint will work even if the client does not
   * provide any of the fields.
   */
export const editReviewSchema = z.object({
  rating: z.number().int().min(1).max(5).optional(),
  reviewText: z.string().optional(),
  imageToken: z.string().optional()
})

    /** 
   * The schema for the fetch reviews endpoint.
   *
   * The fetch reviews endpoint takes three optional query parameters:
   * - `offset`: The number of reviews to skip before returning the next `limit` reviews.
   *   Defaults to 0 if not provided.
   * - `sort`: The field to sort the reviews by. Can be either 'date' or 'rating'.
   *   Defaults to 'date' if not provided.
   * - `order`: The order to sort the reviews in. Can be either 'asc' or 'desc'.
   *   Defaults to 'desc' if not provided.
   */
export const fetchReviewsSchema = z.object({
  offset: z.number().optional().default(0),
  sort: z.enum(['date', 'rating']).optional().default('date'),
  order: z.enum(['asc', 'desc']).optional().default('desc')
})