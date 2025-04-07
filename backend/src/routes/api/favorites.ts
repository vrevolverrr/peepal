import { Hono } from 'hono'
import { db } from '../../app'
import { favorites } from '../../db/schema'
import { eq, and, desc } from 'drizzle-orm'
import { validator } from '../../lib/validator'
import { addFavoriteSchema, deleteFavoriteSchema } from '../../validators/api/favorites'

const favoritesApi = new Hono()

// Route-wide error handler
favoritesApi.onError((err, c) => {
  const logger = c.get('logger')
  logger.error('Error in favorites API', err)

  return c.json({ error: err.message }, 500)
})

// GET /api/favorites - Health Check
favoritesApi.get('/', async (c) => {
  return c.json({ message: 'Favourites Endpoint Health Check'}, 200)
})

// POST /api/favorites/add - Add a toilet to favorites
favoritesApi.post('/add', validator('json', addFavoriteSchema), async (c) => {
  const logger = c.get('logger')
  const userId = c.get('user').id
  const { toiletId } = c.req.valid('json')

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
      return c.json({ error: 'Toilet is already in favorites' }, 400)
    }

    // Add to favorites
    const [favorite] = await db
      .insert(favorites)
      .values({
        userId,
        toiletId,
      })
      .returning()

    logger.info(`User ${userId} added toilet ${toiletId} to favorites`)
    return c.json({ favorite }, 201)
})

// GET /api/favorites/me - Fetch all toilets saved by a user
favoritesApi.get('/me', async (c) => {
  const logger = c.get('logger')
  const userId = c.get('user').id

  // Fetch favorites and map the results
  const dbFavorites = await db
    .select()
    .from(favorites)
    .where(eq(favorites.userId, userId))
    .orderBy(desc(favorites.createdAt))

  const favoriteEntries = dbFavorites.map(fav => ({
    id: fav.id,
    userId: fav.userId,
    toiletId: fav.toiletId,
    createdAt: fav.createdAt.toISOString()
  }))

  logger.info(`User ${userId} fetched their favorites`)
  return c.json({ favorites: favoriteEntries }, 200)
})

// DELETE /api/favorites/remove - Remove a favorite
favoritesApi.delete('/remove', validator('json', deleteFavoriteSchema), async (c) => {
  const logger = c.get('logger')
  const userId = c.get('user').id

  const { toiletId } = c.req.valid('json')

  // Check if the favorite exists
  const [favorite] = await db
    .select()
    .from(favorites)
    .where(and(eq(favorites.userId, userId), eq(favorites.toiletId, toiletId)))

  if (!favorite) {
    return c.json({ error: 'Favorite not found' }, 404)
  }

  // Delete the favorite
  await db.delete(favorites).where(eq(favorites.id, favorite.id))
  logger.info(`User ${userId} removed favorite ${toiletId}`)
  
  return c.json({ message: 'Favorite removed successfully' }, 200)
})

export default favoritesApi