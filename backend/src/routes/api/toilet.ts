import { Hono } from "hono";
import { db } from "../../app"
import { toilets } from "../../db/schema"
import { eq } from "drizzle-orm"

export const toiletApi = new Hono()

//api/toilets/ CREATING TOILET
toiletApi.post('/', async (c) => {
  const logger = c.get('logger')
  const body = await c.req.json()

  // Input validation: Ensure required fields are present
  if (!body.name || !body.address || !body.location || body.toiletAvail === undefined) {
    return c.json({ error: 'Missing required fields: name, address, location, or toiletAvail' }, 400) // Return 400 if any required field is missing
  }

  try {
    const newToilet = await db.insert(toilets).values ({
          id: body.id,
          name: body.name,
          address: body.address,
          location: body.location,
          toiletAvail: body.toiletAvail,
          handicapAvail: body.handicapAvail,
          bidetAvail: body.bidetAvail,
          showerAvail: body.showerAvail,
          sanitiserAvail: body.sanitiserAvail,
          crowdLevel: body.crowdLevel,
          rating: body.rating,
          imageUrl: body.imageUrl,
          reportCount: body.reportCount
    }).returning()
  
    return c.json({ toilet: newToilet }, 200)
  } catch (error) {
    logger.error(`Error creating toilet`, error)
    return c.json({ error: 'Internal server error' }, 500)
  }
})


export default toiletApi
