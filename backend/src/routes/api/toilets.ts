import { nanoid } from "nanoid";
import { Hono } from "hono";
import { Client, DirectionsRoute, RouteLeg, TravelMode } from "@googlemaps/google-maps-services-js";
import { db } from "../../app"
import { toilets } from "../../db/schema"
import { and, eq, getTableColumns, sql } from "drizzle-orm"
import { validator } from "../../lib/validator"
import { createToiletSchema, imageToiletSchema, navigateToiletSchema, nearbyToiletSchema, reportToiletSchema, searchToiletSchema, updateToiletSchema } from "../../validators/api/toilets"

const NUM_REPORTS_DELETE = 3

// Google Maps API Client
const client = new Client()

const toiletApi = new Hono()

toiletApi.onError((err, c) => {
  const logger = c.get('logger')
  logger.error('Error in toilets API', err)

  return c.json({ error: err.message }, 500)
})

// GET /api/toilets - Health Check
toiletApi.get('/', async (c) => {
  return c.json({ message: 'Toilets Endpoint Health Check'}, 200)
})

// POST /api/toilets/create - Create a new toilet
toiletApi.post('/create', validator('json', createToiletSchema), async (c) => {
  const logger = c.get('logger')
  const { name, address, location, handicapAvail, bidetAvail, showerAvail, sanitiserAvail } 
    = c.req.valid('json')

  const toiletId: string = nanoid();

  const [ newToilet ] = await db.insert(toilets).values({
        id: toiletId,
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

  return c.json({ toilet: newToilet }, 201)
})

// PATCH /api/toilets/details/:id - Update an existing toilet
toiletApi.patch('/details/:id', validator('json', updateToiletSchema), async (c) => {  
  const logger = c.get('logger')
  const toiletId = c.req.param('id')

  const body = c.req.valid('json')
  
   // Check if toilet exists
    const [ existingToilet ] = await db
      .select()
      .from(toilets)
      .where(eq(toilets.id, toiletId));

    if (!existingToilet) {
      logger.error(`Toilet not found with ID: ${toiletId}`)
      return c.json({ error: 'Toilet not found' }, 404);
    }

    const [ updatedToilet ] = await db
      .update(toilets)
      .set(body)
      .where(eq(toilets.id, toiletId))
      .returning()

    logger.info(`Toilet ${toiletId} updated`)

    return c.json({ toilet: updatedToilet}, 200)
})

// GET /api/toilets/:id - Get a specific toilet
toiletApi.get('/details/:id', async c => {
  const logger = c.get('logger')
  const toiletId = c.req.param('id')

  const [toilet] = await db
  .select()
  .from(toilets)
  .where(eq(toilets.id, toiletId))

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
    .where(eq(toilets.id, toiletId))

  if (!existingToilet) {
    logger.error(`Toilet not found with ID: ${toiletId}`)
    return c.json({ error: 'Toilet not found' }, 400)
  }

  const numReports = existingToilet.reportCount || 0
  const updatedReportCount = numReports + 1

  if (updatedReportCount >= NUM_REPORTS_DELETE) {
    await db.delete(toilets).where(eq(toilets.id, toiletId))
    logger.info(`Toilet ${toiletId} deleted due to ${NUM_REPORTS_DELETE} reports`)
    
    return c.json({ report: { id: Number(toiletId) } }, 200)
  }

  const [ updatedToilet ] = await db
    .update(toilets)
    .set({ reportCount: updatedReportCount })
    .where(eq(toilets.id, toiletId))
    .returning()

  logger.info(`Toilet ${toiletId} reported`)

  return c.json({ report: updatedToilet }, 200)
})

// GET /api/toilets/nearby - Get toilets within a radius
toiletApi.get('/nearby', validator('query', nearbyToiletSchema), async (c) => {
  const logger = c.get('logger')
  const { latitude, longitude } = c.req.valid('query')

  const sqlPoint = sql`ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)`

  const nearbyToilets = await db
    .select({
      ...getTableColumns(toilets),
      distance: sql`ST_Distance(${toilets.location}, ${sqlPoint})`,
    })
    .from(toilets)
    .orderBy(sql`${toilets.location} <-> ${sqlPoint}`)
    .limit(5);

  logger.info(`Toilets fetched`)

  return c.json({ toilets: nearbyToilets }, 200)
})

toiletApi.post('/search', validator('json', searchToiletSchema), async (c) => {
  const logger = c.get('logger')
  const { query, latitude, longitude, radius, handicapAvail, bidetAvail, showerAvail, sanitiserAvail } = c.req.valid('json')

  const sqlPoint = sql`ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)`

  const searchedToilets = await db.select({
    ...getTableColumns(toilets),
    distance: sql`ST_Distance(${toilets.location}, ${sqlPoint})`,
  })
    .from(toilets)
    .where(
      and(
        sql`ST_DWithin(${toilets.location}, ${sqlPoint}, ${radius ?? 1000.0}::double precision)`,
        sql`to_tsvector('english', ${toilets.address}) @@ plainto_tsquery('english', ${query})`
      )
    )
    .orderBy(sql`${toilets.location} <-> ${sqlPoint}`)
    .limit(5)

  const searchToiletResults: typeof searchedToilets = []

  // Filter toilets additionally
  for (const t of searchedToilets) {
    if (handicapAvail !== undefined && t.handicapAvail !== null && t.handicapAvail !== handicapAvail) continue
    if (bidetAvail !== undefined && t.bidetAvail !== null && t.bidetAvail !== bidetAvail) continue
    if (showerAvail !== undefined && t.showerAvail !== null && t.showerAvail !== showerAvail) continue
    if (sanitiserAvail !== undefined && t.sanitiserAvail !== null && t.sanitiserAvail !== sanitiserAvail) continue

    searchToiletResults.push({ ...t, distance: Math.round(t.distance as number) })
  }

  logger.info(`Toilets fetched`)

  return c.json({ toilets: searchToiletResults }, 200)
})

// GET /api/toilets/image/:id - Get a specific toilet's image
toiletApi.get('/image/:id', validator('query', imageToiletSchema), async (c) => {
  const logger = c.get('logger')
  const { id } = c.req.valid('query')

  // const [toilet] = await db
  // .select()
  // .from(toilets)
  // .where(eq(toilets.id, Number(id)))

  // if (!toilet) {
  //   logger.error(`Toilet not found with ID: ${id}`)
  //   return c.json({ error: 'Toilet not found' }, 404)
  // }

  // logger.info(`Toilet ${id} image fetched`)

  return c.json({ image: undefined }, 200)
})

toiletApi.post('/navigate', validator('json', navigateToiletSchema), async (c) => {
  const logger = c.get('logger')
  const { toiletId, latitude, longitude } = c.req.valid('json')

  const toilet = await db.select().from(toilets).where(eq(toilets.id, toiletId))

  if (!toilet) {
    logger.error(`Toilet not found with ID: ${toiletId}`)
    return c.json({ error: 'Toilet not found' }, 400)
  }

  const response = await client.directions({
    params: {
      origin: `${latitude},${longitude}`,
      destination: `${toilet[0].location.y},${toilet[0].location.x}`,
      mode: TravelMode.walking,
      key: "AIzaSyDSifuva40JMqVs8o-MsON4QjmELzP4AMA"
    }
  })

  const route: DirectionsRoute = response.data.routes[0]
  const leg: RouteLeg = route.legs[0]

  if (!route) {
    logger.error(`No route found from ${latitude}, ${longitude} to ${toiletId}`)
    return c.json({ error: 'No route found' }, 400)
  }

  const steps = leg.steps
  const directions: any = []

  for (const step of steps) {
    directions.push({
      distance: step.distance.text,
      duration: step.duration.text,
      polyline: step.polyline.points,
      start_location: step.start_location,
      end_location: step.end_location,
      instructions: step.html_instructions.replaceAll("<b>", "").replaceAll("</b>", "")
    })
  }

  logger.info(`Navigation requested from ${latitude}, ${longitude} to ${toiletId}`)

  return c.json({ 
    overview_polyline: route.overview_polyline.points, 
    start_address: leg.start_address,
    end_address: leg.end_address,
    start_location: leg.start_location,
    end_location: leg.end_location,
    distance: leg.distance.text, 
    duration: leg.duration.text,
    directions: directions
  }, 200)
})

export default toiletApi