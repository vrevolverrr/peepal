import { nanoid } from "nanoid";
import { Hono } from "hono";
import axios from "axios";
import simplify from "simplify-js";
import { encode, LatLng } from "@googlemaps/polyline-codec";
import { eq, getTableColumns, inArray, sql } from "drizzle-orm"
import {  MapKitAccessToken, MKRoute, MKStep, MKDirections, MKCoordinate, RouteDirection, Route } from "../../types/mapkit";
import { db, minio } from "../../app"
import { toilets } from "../../db/schema"
import { images } from "../../db/schema/images"
import { validator } from "../../middleware/validator"
import { createToiletSchema, getAddressSchema, multiToiletIdSchema, navigateToiletSchema, nearbyToiletSchema, searchToiletSchema, toiletIdParamSchema, updateToiletSchema } from "../../validators/api/toilets"
import { imageUploadSchema } from "../../validators/api/images"
import pino from "pino";

// The constant for the server-side configuration of the number of times
// a toilet has to be reported for non existence for it to be deleted.
const NUM_REPORTS_DELETE = 3

// MapKit API Client
const mapKitAxios = axios.create({
  baseURL: 'https://maps-api.apple.com/v1',
  headers: {
    'Authorization': `Bearer ${process.env.MAPKIT_API_KEY}`
  }
})

/**
 * The Hono instance for the toilets API.
 */
const toiletApi = new Hono()

/**
 * The cached MapKit access token.
 */
var mapsAccessToken: MapKitAccessToken | undefined = undefined

/**
 * Retrieves a MapKit access token.
 * 
 * If the cached token is valid, it returns the cached token.
 * Otherwise, it refreshes the token and returns the new token.
 * 
 * @param {pino.Logger} logger - The logger instance.
 * 
 * @returns {Promise<string>} - The MapKit access token.
 */
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

/**
 * Retrieves the address from the given coordinates.
 * 
 * @param {pino.Logger} logger - The logger instance.
 * @param {number} latitude - The latitude of the coordinates.
 * @param {number} longitude - The longitude of the coordinates.
 * 
 * @returns {Promise<{ placeName: string, address: string }>} - The place name and address.
 */
const getAddressFromCoordinates = async (logger: pino.Logger, latitude: number, longitude: number): Promise<{ placeName: string; address: string; }> => {
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

/**
 * Formats the duration in seconds into a human-readable format.
 * 
 * @param {number} seconds - The duration in seconds.
 * 
 * @returns {string} - The formatted duration.
 */
const formatDuration = (seconds: number): string => {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);

  if (hours > 0) {
    return `${hours} hr ${minutes} min`;
  }

  return `${minutes} min`;
}

/**
 * Formats the distance in meters into a human-readable format.
 * 
 * @param {number} meters - The distance in meters.
 * 
 * @returns {string} - The formatted distance.
 */
const formatDistance = (meters: number): string => {
  if (meters < 1000) {
    return `${meters} meters`;
  }

  return `${(meters / 1000).toFixed(1)} km`;  
}

/**
 * Error handler for the toilets API.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {Error} err - The error object.
 */
toiletApi.onError((err, c) => {
  const logger = c.get('logger')
  logger.error(`Error in toilets API ${err}`)

  return c.json({ error: err.message }, 500)
})

/**
 * GET /api/toilets - Health Check
 *
 * @param {Context} c - The Hono Context object.
 * 
 * @returns {Promise<{ message: string }>} - The health check message.
 */
toiletApi.get('/', async (c) => {
  return c.json({ message: 'Toilets Endpoint Health Check'}, 200)
})

/**
 * POST /api/toilets/create - Creates a new toilet based on the provided information.
 * 
 * The request body is validated using the defined schema to ensure correct data types and structure.
 * 
 * The location field is converted to a spatial point and inserted into the database.
 * 
 * Logs the creation operation and returns the created toilet information upon success.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {CreateToiletSchema} name - The name of the toilet.
 * @param {CreateToiletSchema} address - The address of the toilet.
 * @param {CreateToiletSchema} latitude - The latitude of the toilet's location.
 * @param {CreateToiletSchema} longitude - The longitude of the toilet's location.
 * @param {CreateToiletSchema} location - The location of the toilet.
 * @param {CreateToiletSchema} handicapAvail - Whether the toilet has handicap facilities.
 * @param {CreateToiletSchema} bidetAvail - Whether the toilet has a bidet.
 * @param {CreateToiletSchema} showerAvail - Whether the toilet has a shower.
 * @param {CreateToiletSchema} sanitiserAvail - Whether the toilet has a sanitiser.
 * @param {CreateToiletSchema} rating - The rating of the toilet.
 * 
 * @returns {Promise<{ toilet: Toilet }>} - The created toilet details or an error message.
 */
toiletApi.post('/create', validator('json', createToiletSchema), async (c) => {
  const logger = c.get('logger')
  const { name, address, latitude, longitude, location, handicapAvail, bidetAvail, showerAvail, sanitiserAvail, rating } 
    = c.req.valid('json')

  // Generate a unique ID for the new toilet
  const toiletId: string = nanoid();

  const [ newToilet ] = await db.insert(toilets).values({
        id: toiletId,
        name,
        address,
        // Convert location to a spatial point IMPORTANT! Use SRID 4326
        location: sql`ST_SetSRID(ST_MakePoint(${location.x}, ${location.y}), 4326)`,
        handicapAvail,
        bidetAvail,
        showerAvail,
        sanitiserAvail,
        rating: sql`${rating}::decimal`
  }).returning()

  const sqlPoint = sql`ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)`

  const [ toilet ] = await db
  .select({
    ...getTableColumns(toilets),
    distance: sql`ROUND(ST_Distance(${toilets.location}::geography, ${sqlPoint}::geography) * 1.4)`,
  })
  .from(toilets)
  .where(eq(toilets.id, newToilet.id))

  logger.info(`Toilet ${newToilet.id} created`)

  return c.json({ toilet: toilet }, 201)
})

/**
 * PUT /api/toilets/update/:toiletId - Updates the details of an existing toilet specified by the toiletId.
 * 
 * Validates the request parameters and JSON body using defined schemas to ensure
 * correct data types and structure. If the toilet with the specified ID does not
 * exist, a 404 error is returned. 
 * 
 * The location field, if present in the request body, is converted to a spatial
 * point and updated in the database. If not provided, the existing location is used.
 * 
 * Logs the update operation and returns the updated toilet information upon success.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {ToiletIdParamSchema} toiletId - The ID of the toilet to update.
 * @param {UpdateToiletSchema} name - The name of the toilet.
 * @param {UpdateToiletSchema} address - The address of the toilet.
 * @param {UpdateToiletSchema} location - The location of the toilet.
 * @param {UpdateToiletSchema} handicapAvail - Whether the toilet has handicap facilities.
 * @param {UpdateToiletSchema} bidetAvail - Whether the toilet has a bidet.
 * @param {UpdateToiletSchema} showerAvail - Whether the toilet has a shower.
 * @param {UpdateToiletSchema} sanitiserAvail - Whether the toilet has a sanitiser.
 * 
 * @returns {Promise<{ toilet: Toilet }>} - The updated toilet details or an error message.
 */
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
    
    const sqlPoint = body.location != undefined ? 
      sql`ST_SetSRID(ST_MakePoint(${body.location.x}, ${body.location.y}), 4326)` 
      : sql`ST_SetSRID(ST_MakePoint(${existingToilet.location.x}, ${existingToilet.location.y}), 4326)`

    const [ updatedToilet ] = await db
      .update(toilets)
      .set({
        ...body,
        location: sqlPoint
      })
      .where(eq(toilets.id, toiletId))
      .returning()

    logger.info(`Toilet ${toiletId} updated`)

    return c.json({ toilet: updatedToilet }, 200)
})

/**
 * POST /api/toilets/details - Retrieves a list of toilets based on the provided IDs.
 * 
 * The request body is validated using the defined schema to ensure correct data types and structure.
 * 
 * Logs the retrieval operation and returns the list of toilets upon success.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {MultiToiletIdSchema} toiletIds - The array of toiletIds to fetch details for.
 * 
 * @returns {Promise<{ toilets: Toilet[] }>} - The list of toilets or an error message.
 */
toiletApi.post('/details', validator('json', multiToiletIdSchema), async (c) => {
  const logger = c.get('logger')
  const { toiletIds } = c.req.valid('json')

  const toiletList = await db
    .select()
    .from(toilets)
    .where(inArray(toilets.id, toiletIds))

  logger.info(`Toilets fetched ${toiletList.map((x) => x.id).join(', ')}`)

  return c.json({ toilets: toiletList }, 200)
})

/**
 * GET /api/toilets/details/:toiletId - Retrieves a specific toilet based on the provided ID.
 * 
 * The request parameters are validated using the defined schema to ensure correct data types and structure.
 * 
 * Logs the retrieval operation and returns the toilet information upon success.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {ToiletIdParamSchema} toiletId - The ID of the toilet to retrieve.
 * 
 * @returns {Promise<{ toilet: Toilet }>} - The toilet details or an error message.
 */
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

/**
 * POST /api/toilets/report/:toiletId - Reports a specific toilet based on the provided ID.
 * 
 * The request parameters are validated using the defined schema to ensure correct data types and structure.
 * 
 * Logs the reporting operation and returns the toilet information upon success.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {ToiletIdParamSchema} toiletId - The ID of the toilet to report.
 * 
 * @returns {Promise<{ toilet: Toilet }>} - The toilet details or an error message.
 */
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

/**
 * GET /api/toilets/nearby - Retrieves a list of toilets within a specified radius.
 * 
 * The default radius is 5km and the default limit is 5.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {NearbyToiletSchema} latitude - The latitude of the user's current location.
 * @param {NearbyToiletSchema} longitude - The longitude of the user's current location.
 * @param {NearbyToiletSchema} radius - The radius in kilometers to search for toilets.
 * @param {NearbyToiletSchema} limit - The maximum number of toilets to return.
 * 
 * @returns {Promise<{ toilets: Toilet[] }>} - The list of toilets or an error message.
 */
toiletApi.get('/nearby', validator('query', nearbyToiletSchema), async (c) => {
  const logger = c.get('logger')
  const { latitude, longitude, radius, limit } = c.req.valid('query')

  // IMPORTANT! Use SRID as 4326
  const sqlPoint = sql`ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)`

  const nearbyToilets = await db
    .select({
      ...getTableColumns(toilets),
      // Estimated Harversine distance in meters, multiplied by 1.4 as an approximation adjuster
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

/**
 * POST /api/toilets/search - Searches for toilets based on the provided query.
 * 
 * The request body is validated using the defined schema to ensure correct data types and structure.
 * 
 * Logs the search operation and returns the list of toilets upon success.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {SearchToiletSchema} query - The search query.
 * @param {SearchToiletSchema} latitude - The latitude of the user's current location.
 * @param {SearchToiletSchema} longitude - The longitude of the user's current location.
 * @param {SearchToiletSchema} handicapAvail - Whether the toilet has handicap facilities.
 * @param {SearchToiletSchema} bidetAvail - Whether the toilet has a bidet.
 * @param {SearchToiletSchema} showerAvail - Whether the toilet has a shower.
 * @param {SearchToiletSchema} sanitiserAvail - Whether the toilet has a sanitiser.
 * 
 * @returns {Promise<{ toilets: Toilet[] }>} - The list of toilets or an error message.
 */
toiletApi.post('/search', validator('json', searchToiletSchema), async (c) => {
  const logger = c.get('logger')
  const { query, latitude, longitude, handicapAvail, bidetAvail, showerAvail, sanitiserAvail } = c.req.valid('json')

  const sqlPoint = sql`ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)`

  // Remove special characters from query
  const sanitizedQuery = query.replace(/[^\w\s]/gi, '');

  const searchedToilets = await db
    .select({
      ...getTableColumns(toilets),
      distance: sql`ROUND(ST_Distance(${toilets.location}::geography, ${sqlPoint}::geography))`,
      rank: sql`ts_rank_cd(to_tsvector('english', ${toilets.address}), phraseto_tsquery('english', ${sanitizedQuery}))`,
      exact_match: sql`${toilets.address} ILIKE ${query}`
    })
    .from(toilets)
    .where(
      sql`
        to_tsvector('english', ${toilets.address}) @@ phraseto_tsquery('english', ${sanitizedQuery})
        OR ${toilets.address} ILIKE ${'%' + sanitizedQuery + '%'}
      `
    )
    .orderBy(
      sql`${toilets.address} ILIKE ${query} DESC`,
      sql`ts_rank_cd(to_tsvector('english', ${toilets.address}), phraseto_tsquery('english', ${sanitizedQuery})) DESC`,
      sql`ST_Distance(${toilets.location}::geography, ${sqlPoint}::geography) ASC`
    )
    .limit(6);
  
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

/**
 * POST /api/toilets/navigate/:toiletId - Retrieves navigation instructions to a specific toilet using the Apple MapKit API.
 * 
 * The request parameters are validated using the defined schema to ensure correct data types and structure.
 * 
 * Logs the navigation operation and returns the navigation instructions upon success.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {ToiletIdParamSchema} toiletId - The ID of the toilet to navigate to.
 * @param {NavigateToiletSchema} latitude - The latitude of the user's current location.
 * @param {NavigateToiletSchema} longitude - The longitude of the user's current location.
 * 
 * @returns {Promise<{ navigation: Navigation }>} - The navigation instructions or an error message.
 */
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
  
  /// Parse the response from MapKit into our own format
  const mkRoute: MKRoute = directionsResponse.data.routes[0]
  const mkSteps: MKStep[] = directionsResponse.data.steps
  const mkStepPaths: MKCoordinate[][] = directionsResponse.data.stepPaths

  const stepPathTransformed: LatLng[][] = mkStepPaths.map(stepPath => stepPath.map(coord => ({ lat: coord.latitude, lng: coord.longitude })))
  /// Encode the step paths (LatLngs) into polyline strings for more efficient transmission and parsing on the frontend.
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

  /// Simplifies the points of the full route polyline while preserving the shape
  const overviewPolyline: string = encode(simplify(overviewPolylinePoints, 0.0001, false).map(coord => [coord.y, coord.x]))

  /// Format the distance and duration
  const distanceString: string = formatDistance(mkRoute.distanceMeters)
  const durationString: string = formatDuration(mkRoute.durationSeconds)

  /// Create the route object
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

/**
 * POST /api/toilets/address - Retrieves the address from the given coordinates (reverse geocoding) using the Apple MapKit API.
 * 
 * The request body is validated using the defined schema to ensure correct data types and structure.
 * 
 * Logs the retrieval operation and returns the address upon success.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {GetAddressSchema} latitude - The latitude of the coordinates.
 * @param {GetAddressSchema} longitude - The longitude of the coordinates.
 * 
 * @returns {Promise<{ address: string }>} - The address or an error message.
 */
toiletApi.post('/getAddress', validator('json', getAddressSchema), async (c) => {
  const logger = c.get('logger')
  const { latitude, longitude } = c.req.valid('json')

  const address = await getAddressFromCoordinates(logger, latitude, longitude)
  
  return c.json({ address }, 200)
})

/**
 * POST /api/toilets/updateImage/:toiletId - Updates the image of an existing toilet specified by the toiletId.
 * 
 * Validates the request parameters and form data using defined schemas to ensure
 * correct data types and structure. The image is uploaded to an S3 bucket and
 * the image token is updated in the database.
 * 
 * Logs the update operation and returns the updated toilet information upon success.
 * 
 * @param {Context} c - The Hono Context object.
 * @param {ToiletIdParamSchema} toiletId - The ID of the toilet to update.
 * @param {ImageUploadSchema} image - The image to upload.
 * 
 * @returns {Promise<{ toilet: Toilet }>} - The updated toilet details or an error message.
 */
toiletApi.patch('/image/:toiletId', 
  validator('param', toiletIdParamSchema),
  validator('form', imageUploadSchema),
  async (c) => {
    const logger = c.get('logger')
    const { toiletId } = c.req.valid('param')

    // Check if toilet exists
    const [existingToilet] = await db
      .select()
      .from(toilets)
      .where(eq(toilets.id, toiletId))

    if (!existingToilet) {
      logger.error(`Toilet not found with ID: ${toiletId}`)
      return c.json({ error: 'Toilet not found' }, 404)
    }

    // Delete old image if it exists
    if (existingToilet.imageToken) {
      const [oldImage] = await db
        .select()
        .from(images)
        .where(eq(images.token, existingToilet.imageToken))

      if (oldImage) {
        try {
          await minio.removeObject(process.env.S3_BUCKET || '', oldImage.filename)
          await db.delete(images).where(eq(images.token, oldImage.token))
          logger.info(`Deleted old image: ${oldImage.filename}`)
        } catch (e) {
          logger.error(`Failed to delete old image: ${e}`)
        }
      }
    }

    // Upload new image
    const form = await c.req.parseBody()
    const image = form.image as File
    const token = nanoid()
    const extension = image.name.split('.').pop()
    const objectName = `${token}.${extension}`

    const buffer = await image.arrayBuffer()

    await minio.putObject(
      process.env.S3_BUCKET || '',
      objectName,
      Buffer.from(buffer),
      image.size,
      { 'Content-Type': image.type }
    )

    await db.insert(images).values({
      token,
      type: form.type as string,
      userId: c.get('user').id,
      filename: objectName,
      uploadedAt: new Date()
    })

    // Update toilet with new image token
    const [updatedToilet] = await db
      .update(toilets)
      .set({ imageToken: token })
      .where(eq(toilets.id, toiletId))
      .returning()

    logger.info(`Updated toilet image: ${toiletId}`)
    return c.json({ toilet: updatedToilet }, 200)
  }
)

export default toiletApi