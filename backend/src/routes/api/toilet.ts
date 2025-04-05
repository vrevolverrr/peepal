import { Hono } from "hono";
import { db } from "../../app"
import { toilets } from "../../db/schema"
import { eq } from "drizzle-orm"

export const toiletApi = new Hono()

//api/toilets/ CREATING TOILET
toiletApi.post('/create', async (c) => {
  const logger = c.get('logger')
  const body = await c.req.json()

  // Input validation
  if (!body.name || !body.address || !body.location || body.toiletAvail === undefined) {
    return c.json({ error: 'Missing required fields: name, address, location, or toiletAvail' }, 400) // Return 400 if any required field is missing
  }

  try {
    const [newToilet] = await db.insert(toilets).values ({
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

//api/toilets/:id Changing Toilet information
toiletApi.put('/:id', async (c) => {
  const logger = c.get('logger')
  const toiletId = c.req.param('id')
  const body = await c.req.json()
  
  console.log('PUT request details:', {
    url: c.req.url,
    path: c.req.path,
    params: c.req.param(),
    toiletId
  });

  try {
    // First check if toilet exists
    const [existingToilet] = await db
      .select()
      .from(toilets)
      .where(eq(toilets.id, Number(toiletId)));

    console.log('Existing toilet:', existingToilet);

    if (!existingToilet) {
      console.log('No toilet found with ID:', toiletId);
      return c.json({ error: 'Toilet not found' }, 404);
    }

    const [updatedToilet] = await db
      .update(toilets)
      .set(body)
      .where(eq(toilets.id, Number(toiletId)))
      .returning()

    console.log('Updated toilet result:', updatedToilet);

    return c.json({ toilet: updatedToilet}, 200)
  } catch (error) {
    logger.error(`Error updating toilet ${toiletId}`, error)
    console.log('Error details:', error);
    return c.json({ error: 'Internal server error' }, 500)
  }
})

//api/toilets/id Deleting Toilet
toiletApi.delete('/:id', async c => {
  const logger = c.get('logger')
  const toiletId = c.req.param('id')

  try {
    const [deletedToilet] = await db
    .delete(toilets)
    .where(eq(toilets.id, Number(toiletId)))
    .returning()

    if (!deletedToilet) {
      return c.json({ error: 'Toilet not found'}, 404)
    }

    return c.json({toilet: deletedToilet}, 200)
  } catch (error) {
    logger.error(`Error deleting toilet ${toiletId}`, error)
    return c.json({error: 'Internal server error'}, 500)
  }
})

export default toiletApi