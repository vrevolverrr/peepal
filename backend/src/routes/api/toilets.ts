import { nanoid } from "nanoid";
import { Hono } from "hono";
import axios from "axios";
import simplify from "simplify-js";
import { encode, LatLng } from "@googlemaps/polyline-codec";
import { eq, getTableColumns, sql } from "drizzle-orm"
import {  MapKitAccessToken, MKRoute, MKStep, MKDirections, MKCoordinate, RouteDirection, Route } from "../../types/mapkit";
import { db } from "../../app"
import { toilets } from "../../db/schema"
import { validator } from "../../middleware/validator"
import { createToiletSchema, getAddressSchema, navigateToiletSchema, nearbyToiletSchema, searchToiletSchema, toiletIdParamSchema, updateToiletSchema } from "../../validators/api/toilets"
import pino from "pino";

const NUM_REPORTS_DELETE = 3

// MapKit API Client
const mapKitAxios = axios.create({
  baseURL: 'https://maps-api.apple.com/v1',
  headers: {
    'Authorization': `Bearer ${process.env.MAPKIT_API_KEY}`
  }
})

const toiletApi = new Hono()

var mapsAccessToken: MapKitAccessToken | undefined = undefined

const getMapKitAccessToken = async (logger: pino.Logger) => {
  if (mapsAccessToken && mapsAccessToken.expiresAt > new Date()) {
    logger.info("Using cached MapKit access token");
    return mapsAccessToken.accessToken
  } 

  logger.info("MapKit access token expired, refreshing token");
  const response: any = await mapKitAxios.get('/token')

  const accessToken = response.data.accessToken
  // Offset by 60 seconds to prevent expiration
  const expiresAt = new Date(Date.now() + response.data.expiresInSeconds * 1000 - 60)
  
  mapsAccessToken = { accessToken, expiresAt }
  
  logger.info("Obtained new MapKit access token");
  return accessToken
}

const getAddressFromCoordinates = async (logger: pino.Logger, latitude: number, longitude: number) => {
  const accessToken = await getMapKitAccessToken(logger)

  type MKReverseGeocodeData = {
    results: {
      name: string
      formattedAddressLines: string[]
    }[]
  }

  logger.info(`Getting address from coordinates: ${latitude},${longitude}`)

  const response = await mapKitAxios.get('/reverseGeocode', {
    headers: {
      'Authorization': `Bearer ${accessToken}`
    },
    params: {
      loc: `${latitude},${longitude}`,
    }
  })

  const data = response.data as MKReverseGeocodeData
  
  return {
    placeName: data.results[0].name,
    address: data.results[0].formattedAddressLines.join(', ')
  }
}

const formatDuration = (seconds: number) => {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);

  if (hours > 0) {
    return `${hours} hr ${minutes} min`;
  }

  return `${minutes} min`;
}

const formatDistance = (meters: number) => {
  if (meters < 1000) {
    return `${meters} meters`;
  }

  return `${(meters / 1000).toFixed(1)} km`;  
}

toiletApi.onError((err, c) => {
  const logger = c.get('logger')
  logger.error(`Error in toilets API ${err}`)

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

// PATCH /api/toilets/details/:toiletId - Update an existing toilet
toiletApi.patch('/details/:toiletId', validator('param', toiletIdParamSchema), 
  validator('json', updateToiletSchema), async (c) => {  
  
  const logger = c.get('logger')
  const { toiletId } = c.req.valid('param')

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

// GET /api/toilets/:toiletId - Get a specific toilet
toiletApi.get('/details/:toiletId', validator('param', toiletIdParamSchema), async (c) => {
  const logger = c.get('logger')
  const { toiletId } = c.req.valid('param')

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
toiletApi.post('/report/:toiletId', validator('param', toiletIdParamSchema), async (c) => {
  const logger = c.get('logger')
  const { toiletId } = c.req.valid('param')

  const [ existingToilet ] = await db
    .select()
    .from(toilets)
    .where(eq(toilets.id, toiletId))

  if (!existingToilet) {
    logger.error(`Toilet not found with ID: ${toiletId}`)
    return c.json({ error: 'Toilet not found' }, 404)
  }

  const numReports = existingToilet.reportCount || 0
  const updatedReportCount = numReports + 1

  if (updatedReportCount >= NUM_REPORTS_DELETE) {
    await db.delete(toilets).where(eq(toilets.id, toiletId))
    logger.info(`Toilet ${toiletId} deleted due to ${NUM_REPORTS_DELETE} reports`)
    
    return c.json({ message: 'Toilet reported and deleted after reaching threshold', deleted: true }, 200)
  }

  await db
    .update(toilets)
    .set({ reportCount: updatedReportCount })
    .where(eq(toilets.id, toiletId))

  logger.info(`Toilet ${toiletId} reported`)

  return c.json({ message: 'Toilet reported', deleted: false }, 200)
})

// GET /api/toilets/nearby - Get nearest toilets
toiletApi.get('/nearby', validator('query', nearbyToiletSchema), async (c) => {
  const logger = c.get('logger')
  const { latitude, longitude, radius, limit } = c.req.valid('query')

  const sqlPoint = sql`ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)`

  const nearbyToilets = await db
    .select({
      ...getTableColumns(toilets),
      distance: sql`ROUND(ST_Distance(${toilets.location}::geography, ${sqlPoint}::geography) * 1.4)`,
    })
    .from(toilets)
    // Default radius is 5km and clamp at 5km
    .where(sql`ST_DWithin(${toilets.location}, ${sqlPoint}, ${Math.max(0, Math.min(Number(radius ?? 5.0), 5.0))}::double precision)`)
    .orderBy(sql`${toilets.location} <-> ${sqlPoint}`)
    .limit(Number(limit ?? 5));

  logger.info(`Toilets fetched`)

  return c.json({ toilets: nearbyToilets }, 200)
})

toiletApi.post('/search', validator('json', searchToiletSchema), async (c) => {
  const logger = c.get('logger')
  const { query, latitude, longitude, handicapAvail, bidetAvail, showerAvail, sanitiserAvail } = c.req.valid('json')

  const sqlPoint = sql`ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)`

  const searchedToilets = await db.select({
    ...getTableColumns(toilets),
    distance: sql`ROUND(ST_Distance(${toilets.location}::geography, ${sqlPoint}::geography))`,
  })
    .from(toilets)
    .where(
      sql`${toilets.address} ILIKE ${'%' + query + '%'}`
    )
    .orderBy(sql`ts_rank(to_tsvector('english', address), plainto_tsquery('english', ${query})) ASC`,
      sql`ST_Distance(${toilets.location}, ${sqlPoint})`)
    .limit(6)

  const searchToiletResults: typeof searchedToilets = []

  // Filter toilets additionally
  for (const t of searchedToilets) {
    if (handicapAvail !== undefined && t.handicapAvail !== null && t.handicapAvail !== handicapAvail) continue
    if (bidetAvail !== undefined && t.bidetAvail !== null && t.bidetAvail !== bidetAvail) continue
    if (showerAvail !== undefined && t.showerAvail !== null && t.showerAvail !== showerAvail) continue
    if (sanitiserAvail !== undefined && t.sanitiserAvail !== null && t.sanitiserAvail !== sanitiserAvail) continue

    searchToiletResults.push(t)
  }

  logger.info(`Toilets fetched`)

  return c.json({ toilets: searchToiletResults }, 200)
})

toiletApi.post('/navigate/:toiletId', validator('param', toiletIdParamSchema), 
validator('json', navigateToiletSchema), async (c) => {
  const logger = c.get('logger')
  const { toiletId } = c.req.valid('param')
  const { latitude, longitude } = c.req.valid('json')

  const [ toilet ] = await db.select().from(toilets).where(eq(toilets.id, toiletId)).limit(1)

  if (!toilet) {
    logger.error(`Toilet not found with ID: ${toiletId}`)
    return c.json({ error: 'Toilet not found' }, 404)
  }

  const accessToken = await getMapKitAccessToken(logger)
  const directionsResponse = await mapKitAxios.get<MKDirections>(
    '/directions', {
      headers: {
        'Authorization': `Bearer ${accessToken}`
      },
      params: {
        'origin': `${latitude},${longitude}`,
        'destination': `${toilet.location.y},${toilet.location.x}`,
        'transportType': 'Walking',
      }
    }
  )
  
  const mkRoute: MKRoute = directionsResponse.data.routes[0]
  const mkSteps: MKStep[] = directionsResponse.data.steps
  const mkStepPaths: MKCoordinate[][] = directionsResponse.data.stepPaths

  const stepPathTransformed: LatLng[][] = mkStepPaths.map(stepPath => stepPath.map(coord => ({ lat: coord.latitude, lng: coord.longitude })))
  const stepPathPolylines: string[] = stepPathTransformed.map(path => encode(path))

  const directions: RouteDirection[] = []

  for (const step of mkSteps) {
    directions.push({
      distance: formatDistance(step.distanceMeters),
      duration: formatDuration(step.durationSeconds),
      polyline: stepPathPolylines[step.stepPathIndex],
      start_location: stepPathTransformed[step.stepPathIndex][0],
      end_location: stepPathTransformed[step.stepPathIndex][stepPathTransformed[step.stepPathIndex].length - 1],
      instructions: step.instructions
    })
  }

  const overviewPolylinePoints: {
    x: number;
    y: number;
  }[] = stepPathTransformed.flat().map(coord => ({ x: coord.lng, y: coord.lat }))

  const overviewPolyline: string = encode(simplify(overviewPolylinePoints, 0.0001, false).map(coord => [coord.y, coord.x]))

  const distanceString: string = formatDistance(mkRoute.distanceMeters)
  const durationString: string = formatDuration(mkRoute.durationSeconds)

  const route: Route = {
    overview_polyline: overviewPolyline,
    start_location: {
      lat: directionsResponse.data.origin.coordinate.latitude,
      lng: directionsResponse.data.origin.coordinate.longitude
    },
    end_location: {
      lat: directionsResponse.data.destination.coordinate.latitude,
      lng: directionsResponse.data.destination.coordinate.longitude
    },
    distance: distanceString,
    duration: durationString,
    directions: directions
  }
  
  return c.json({ route: route }, 200);
})

toiletApi.post('/getAddress', validator('json', getAddressSchema), async (c) => {
  const logger = c.get('logger')
  const { latitude, longitude } = c.req.valid('json')

  const address = await getAddressFromCoordinates(logger, latitude, longitude)
  
  return c.json({ address }, 200)
})

export default toiletApi