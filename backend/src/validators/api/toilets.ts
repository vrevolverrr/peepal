import { z } from 'zod'

export const createToiletSchema = z.object({
  name: z.string().min(1).max(255),
  address: z.string().min(1).max(255),
  location: z.object({
    x: z.number(),
    y: z.number()
  }),
  handicapAvail: z.boolean().optional(),
  bidetAvail: z.boolean().optional(),
  showerAvail: z.boolean().optional(),
  sanitiserAvail: z.boolean().optional(),
})

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

export const reportToiletSchema = z.object({
  toiletId: z.string(),
})

export const nearbyToiletSchema = z.object({
  latitude: z.string(),
  longitude: z.string(),
})

export const searchToiletSchema = z.object({
  query: z.string(),
  latitude: z.number(),
  longitude: z.number(),
  radius: z.number().optional(),
  handicapAvail: z.boolean().optional(),
  bidetAvail: z.boolean().optional(),
  showerAvail: z.boolean().optional(),
  sanitiserAvail: z.boolean().optional(),
})

export const imageToiletSchema = z.object({
  id: z.number(),
})

export const navigateToiletSchema = z.object({
  toiletId: z.string(),
  latitude: z.number(),
  longitude: z.number(),
})