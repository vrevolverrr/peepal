import { Hono } from 'hono'
import { db } from '../../app'
import { favorites, toilets } from '../../db/schema'
import { eq, and, desc, getTableColumns } from 'drizzle-orm'
import { validator } from '../../middleware/validator'
import { toiletIdParamSchema } from '../../validators/api/toilets'

const favoritesApi = new Hono()

// Route-wide error handler
favoritesApi.onError((err, c) => {
  const logger = c.get('logger')  
  logger.error(`Error in favorites API: ${err}`)

  return c.json({ error: err.message }, 500)
})

// GET /api/favorites - Health Check
favoritesApi.get('/', async (c) => {
  return c.json({ message: 'Favourites Endpoint Health Check'}, 200)
})

// GET /api/favorites/me - Fetch all toilets saved by a user
favoritesApi.get('/me', async (c) => {
  const logger = c.get('logger')
  const userId = c.get('user').id

  // Fetch favorites and map the results
  const userFavorites = await db
    .select({
      toiletId: favorites.toiletId,
      createdAt: favorites.createdAt
    })
    .from(favorites)
    .where(eq(favorites.userId, userId))
    .orderBy(desc(favorites.createdAt))

  logger.info(`User ${userId} fetched their favorites`)

  return c.json({ favorites: userFavorites }, 200)
})

// POST /api/favorites/add - Add a toilet to favorites
favoritesApi.post('/add/:toiletId', validator('param', toiletIdParamSchema), async (c) => {
  const logger = c.get('logger')
  const userId = c.get('user').id

  const { toiletId } = c.req.valid('param')
  
  // Check if toilet exists
  const [ existingToilet ] = await db
    .select()
    .from(toilets)
    .where(eq(toilets.id, toiletId))

  if (!existingToilet) {
    logger.error(`Toilet not found with ID: ${toiletId}`)
    return c.json({ error: 'Toilet not found' }, 404)
  }

  // Check if the toilet is already in favorites
  const [ existing ] = await db
    .select()
    .from(favorites)
    .where(
      and(
        eq(favorites.userId, userId),
        eq(favorites.toiletId, toiletId)
      )
    )

  if (existing) {
    logger.info(`Toilet ${toiletId} already in favorites of ${userId}`)
    return c.status(200)
  }

  // Add to favorites
  await db
    .insert(favorites)
    .values({
      userId,
      toiletId,
    })

  logger.info(`User ${userId} added toilet ${toiletId} to favorites`)

  return c.status(200)
})

// DELETE /api/favorites/remove - Remove a favorite
favoritesApi.delete('/remove/:toiletId', validator('param', toiletIdParamSchema), async (c) => {
  const logger = c.get('logger')
  const userId = c.get('user').id

  const { toiletId } = c.req.valid('param')

  const [ existingToilet ] = await db
    .select()
    .from(toilets)
    .where(eq(toilets.id, toiletId))

  if (!existingToilet) {
    logger.info(`Toilet not found with ID: ${toiletId}`)
    return c.json({ error: 'Toilet not found' }, 404)
  }
  
  try {
    const [ favorite ] = await db
      .select()
      .from(favorites)
      .where(and(eq(favorites.userId, userId), eq(favorites.toiletId, toiletId)))

    if (!favorite) {
      logger.info(`No favorite found for user ${userId} and toilet ${toiletId}`)
      return c.json({ error: 'Favorite not found' }, 404)
    }
    
    logger.info(`Favorite found with ID: ${favorite.id}`);

    await db.delete(favorites).where(eq(favorites.id, favorite.id))
    
    logger.info(`User ${userId} removed favorite ${toiletId}`)
    
    return c.status(200)
  } catch (error) {
    logger.error(`Error handling favorite deletion: ${error}`)
    return c.json({ error: 'Server error during favorite deletion' }, 500)
  }
})

export default favoritesApi