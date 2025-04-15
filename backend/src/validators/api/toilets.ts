import { z } from 'zod'

export const toiletIdParamSchema = z.object({
  toiletId: z.string(),
})

export const multiToiletIdSchema = z.object({
  toiletIds: z.array(z.string()),
})

/**
 * The schema for the /api/toilets/create endpoint.
 *
 * This endpoint requires a JSON object with the following fields:
 * - name: A string representing the name of the toilet.
 * - address: A string representing the address of the toilet.
 * - latitude: A number representing the latitude of the toilet's location.
 * - longitude: A number representing the longitude of the toilet's location.
 * - location: A JSON object with the following fields:
 *   - x: A number representing the x-coordinate of the toilet's location.
 *   - y: A number representing the y-coordinate of the toilet's location.
 * - rating: An integer between 1 and 5 representing the rating of the toilet.
 * - handicapAvail: A boolean indicating whether the toilet has handicap facilities.
 * - bidetAvail: A boolean indicating whether the toilet has a bidet.
 * - showerAvail: A boolean indicating whether the toilet has a shower.
 * - sanitiserAvail: A boolean indicating whether the toilet has a sanitiser.
 *
 * All of the above fields must be present in the request body.
 */
export const createToiletSchema = z.object({
  name: z.string().min(1).max(255),
  address: z.string().min(1).max(255),
  latitude: z.number(),
  longitude: z.number(),
  location: z.object({
    x: z.number(),
    y: z.number()
  }),
  rating: z.number().int().min(1).max(5),
  handicapAvail: z.boolean().optional(),
  bidetAvail: z.boolean().optional(),
  showerAvail: z.boolean().optional(),
  sanitiserAvail: z.boolean().optional(),
})

/**
 * The schema for the /api/toilets/:toiletId endpoint.
 *
 * This endpoint requires a JSON object with the following fields:
 * - name: A string representing the name of the toilet.
 * - address: A string representing the address of the toilet.
 * - location: A JSON object with the following fields:
 *   - x: A number representing the x-coordinate of the toilet's location.
 *   - y: A number representing the y-coordinate of the toilet's location.
 * - handicapAvail: A boolean indicating whether the toilet has handicap facilities.
 * - bidetAvail: A boolean indicating whether the toilet has a bidet.
 * - showerAvail: A boolean indicating whether the toilet has a shower.
 * - sanitiserAvail: A boolean indicating whether the toilet has a sanitiser.
 *
 * At least one of the above fields must be present in the request body.
 */
export const updateToiletSchema = z.object({
  name: z.string().min(1).max(255).optional(),
  address: z.string().min(1).max(255).optional(),
  location: z.object({
    x: z.number(),
    y: z.number()
  }).optional(),
  handicapAvail: z.boolean().optional(),
  bidetAvail: z.boolean().optional(),
  showerAvail: z.boolean().optional(),
  sanitiserAvail: z.boolean().optional(),
})

/**
 * The schema for the /api/toilets/nearby endpoint.
 *
 * This endpoint requires a query string with the following fields:
 * - latitude: A string representing the latitude coordinate.
 * - longitude: A string representing the longitude coordinate.
 * 
 * Optional fields:
 * - radius: A string representing the radius in kilometers to search for nearby toilets.
 *   Defaults to 5km if not provided.
 * - limit: A string representing the maximum number of toilets to return.
 *   Defaults to 5 if not provided.
 */
export const nearbyToiletSchema = z.object({
  latitude: z.string(),
  longitude: z.string(),
  radius: z.string().optional(),
  limit: z.string().optional(),
})

/**
 * The schema for the /api/toilets/search endpoint.
 *
 * This endpoint requires a JSON object with several fields:
 * - query: A string representing the search query.
 * - latitude: A number representing the latitude coordinate.
 * - longitude: A number representing the longitude coordinate.
 * 
 * Optional fields:
 * - handicapAvail: A boolean indicating if handicap facilities are available.
 * - bidetAvail: A boolean indicating if a bidet is available.
 * - showerAvail: A boolean indicating if a shower is available.
 * - sanitiserAvail: A boolean indicating if sanitiser is available.
 */
export const searchToiletSchema = z.object({
  query: z.string(),
  latitude: z.number(),
  longitude: z.number(),
  handicapAvail: z.boolean().optional(),
  bidetAvail: z.boolean().optional(),
  showerAvail: z.boolean().optional(),
  sanitiserAvail: z.boolean().optional(),
})

/**
 * The schema for the /api/toilets/navigate endpoint.
 *
 * This endpoint requires a JSON object with two fields: latitude and longitude.
 * Both fields are required and must be numbers representing the geographical
 * coordinates of the user's current location.
 */
export const navigateToiletSchema = z.object({
  latitude: z.number(),
  longitude: z.number(),
})

/**
 * The schema for the /api/toilets/getAddress endpoint.
 *
 * This endpoint requires a JSON object with two fields: latitude and longitude.
 * The latitude and longitude fields are required and must be numbers.
 *
 * The endpoint will return an object with two fields: placeName and address.
 * The placeName field will contain the name of the nearest known
 * location to the given latitude and longitude, and the address field
 * will contain the address of the nearest known location.
 */
export const getAddressSchema = z.object({
  latitude: z.number(),
  longitude: z.number(),
})