import { Hono } from "hono";
import { db } from "../../app"
import { toilets } from "../../db/schema"
import { eq } from "drizzle-orm"

const toiletApi = new Hono()

interface CreateToiletBody {
  name: string
  address: string
  location: {
    x: number
    y: number
  }
  handicapAvail?: boolean
  bidetAvail?: boolean
  showerAvail?: boolean
  sanitiserAvail?: boolean
  crowdLevel?: number
}

// POST /api/toilets/create - Create a new toilet
toiletApi.post('/create', async (c) => {
  const logger = c.get('logger')
  try {
    const body = await c.req.json<CreateToiletBody>()

    const [newToilet] = await db.insert(toilets).values({
          name: body.name,
          address: body.address,
          location: {
            x: body.location.x,
            y: body.location.y
          },
          handicapAvail: body.handicapAvail,
          bidetAvail: body.bidetAvail,
          showerAvail: body.showerAvail,
          sanitiserAvail: body.sanitiserAvail,
          crowdLevel: body.crowdLevel,
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
    const [ existingToilet ] = await db
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

toiletApi.get('/:id', async c => {
  const logger = c.get('logger')
  const toiletId = c.req.param('id')

  try {
    const [toilet] = await db
      .select()
      .from(toilets)
      .where(eq(toilets.id, Number(toiletId)))

    if (!toilet) {
      return c.json({ error: 'Toilet not found' }, 404)
    }

    return c.json({ toilet }, 200)
  } catch (error) {
    logger.error(`Error fetching toilet ${toiletId}`, error)
    return c.json({ error: 'Internal server error' }, 500)
  }
})

export default toiletApi