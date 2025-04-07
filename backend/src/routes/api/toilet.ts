import { Hono } from "hono";
import { db } from "../../app"
import { toilets } from "../../db/schema"
import { eq } from "drizzle-orm"
import { validator } from "../../lib/validator"
import { createToiletSchema, reportToiletSchema, updateToiletSchema } from "../../validators/api/toilet"

const toiletApi = new Hono()

const NUM_REPORTS_DELETE = 3

// POST /api/toilets/create - Create a new toilet
toiletApi.post('/create', validator('json', createToiletSchema), async (c) => {
  const logger = c.get('logger')
  const { name, address, location, handicapAvail, bidetAvail, showerAvail, sanitiserAvail } 
    = c.req.valid('json')

  const [ newToilet ] = await db.insert(toilets).values({
        name,
        address,
        location: {
          x: location.x,
          y: location.y
        },
        handicapAvail,
        bidetAvail,
        showerAvail,
        sanitiserAvail,
  }).returning()

  logger.info(`Toilet ${newToilet.id} created`)

  return c.json({ toilet: newToilet }, 200)
})

// PATCH /api/toilets/:id - Update an existing toilet
toiletApi.patch('/:id', validator('json', updateToiletSchema), async (c) => {
  const logger = c.get('logger')
  const toiletId = c.req.param('id')

  const body = c.req.valid('json')
  
   // Check if toilet exists
    const [ existingToilet ] = await db
      .select()
      .from(toilets)
      .where(eq(toilets.id, Number(toiletId)));

    if (!existingToilet) {
      logger.error(`Toilet not found with ID: ${toiletId}`)
      return c.json({ error: 'Toilet not found' }, 404);
    }

    const [ updatedToilet ] = await db
      .update(toilets)
      .set(body)
      .where(eq(toilets.id, Number(toiletId)))
      .returning()

    logger.info(`Toilet ${toiletId} updated`)

    return c.json({ toilet: updatedToilet}, 200)
})

// GET /api/toilets/:id - Get a specific toilet
toiletApi.get('/:id', async c => {
  const logger = c.get('logger')
  const toiletId = c.req.param('id')

  const [toilet] = await db
  .select()
  .from(toilets)
  .where(eq(toilets.id, Number(toiletId)))

if (!toilet) {
  logger.error(`Toilet not found with ID: ${toiletId}`)
  return c.json({ error: 'Toilet not found' }, 404)
}

logger.info(`Toilet ${toiletId} fetched`)

return c.json({ toilet }, 200)
})

// POST /api/toilets/report - Report a toilet
toiletApi.post('/report', validator('json', reportToiletSchema), async (c) => {
  const logger = c.get('logger')
  const { toiletId } = c.req.valid('json')

  const [ existingToilet ] = await db
    .select()
    .from(toilets)
    .where(eq(toilets.id, Number(toiletId)))

  if (!existingToilet) {
    logger.error(`Toilet not found with ID: ${toiletId}`)
    return c.json({ error: 'Toilet not found' }, 400)
  }

  const numReports = existingToilet.reportCount || 0
  const updatedReportCount = numReports + 1

  if (updatedReportCount >= NUM_REPORTS_DELETE) {
    await db.delete(toilets).where(eq(toilets.id, Number(toiletId)))
    logger.info(`Toilet ${toiletId} deleted due to ${NUM_REPORTS_DELETE} reports`)
    
    return c.json({ report: { id: Number(toiletId) } }, 200)
  }

  const [ updatedToilet ] = await db
    .update(toilets)
    .set({ reportCount: updatedReportCount })
    .where(eq(toilets.id, Number(toiletId)))
    .returning()

  logger.info(`Toilet ${toiletId} reported`)

  return c.json({ report: updatedToilet }, 200)
})

export default toiletApi