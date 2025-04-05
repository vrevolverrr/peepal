import { Hono } from 'hono'
import { db } from '../../app'
import { favorites } from '../../db/schema'
import { eq, and, desc } from 'drizzle-orm'
import { logger } from '../../middleware/logger'

const favoritesApi = new Hono()

// Export the router
export default favoritesApi

// POST /api/favorites - Add a toilet to favorites
favoritesApi.post('/', async (c) => {
  // Verify auth token
  const user = c.get('user')
  if (!user) {
    return c.json({ error: 'Unauthorized' }, 401)
  }
  const logger = c.get('logger')
  const body = await c.req.json()

  const { toiletId } = body
  if (!toiletId) {
    return c.json({ error: 'Invalid input' }, 400)
  }

  try {
    // Check if favorite already exists
    const [existing] = await db
      .select()
      .from(favorites)
      .where(
        and(
          eq(favorites.userId, user.id),
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
        userId: user.id,
        toiletId,
      })
      .returning()

    logger.info(`User ${user.id} added toilet ${toiletId} to favorites`)
    return c.json({ favorite }, 201)
  } catch (err) {
    logger.error('Error adding toilet to favorites', err)
    return c.json({ error: 'Failed to add toilet to favorites' }, 500)
  }
})

// GET /api/favorites/user/:user_id - Fetch all toilets saved by a user
favoritesApi.get('/user/:user_id', async (c) => {
  // Verify auth token
  const user = c.get('user')
  if (!user) {
    return c.json({ error: 'Unauthorized' }, 401)
  }
  const userId = c.req.param('user_id')
  const logger = c.get('logger')

  try {
    // Only allow users to view their own favorites
    if (userId !== user.id) {
      return c.json({ error: 'Not authorized' }, 403)
    }

    // Fetch favorites and map the results
    const dbFavorites = await db
      .select()
      .from(favorites)
      .where(eq(favorites.userId, user.id))
      .orderBy(desc(favorites.createdAt))

    const favoriteEntries = dbFavorites.map(fav => ({
      id: fav.id,
      userId: fav.userId,
      toiletId: fav.toiletId,
      createdAt: fav.createdAt?.toISOString() || null
    }))

    logger.info(`User ${user.id} fetched their favorites`)
    return c.json({ favorites: favoriteEntries }, 200)
  } catch (err) {
    logger.error('Error fetching favorites', err)
    return c.json({ error: 'Failed to fetch favorites' }, 500)
  }
})

// DELETE /api/favorites/:id - Remove a favorite
favoritesApi.delete('/:id', async (c) => {
  // Verify auth token
  const user = c.get('user')
  if (!user) {
    return c.json({ error: 'Unauthorized' }, 401)
  }
  const favoriteId = Number(c.req.param('id'))
  if (isNaN(favoriteId)) {
    return c.json({ error: 'Invalid favorite ID' }, 400)
  }
  const logger = c.get('logger')

  try {
    // First check if the favorite exists
    const [favorite] = await db
      .select()
      .from(favorites)
      .where(eq(favorites.id, favoriteId))

    if (!favorite) {
      return c.json({ error: 'Favorite not found' }, 404)
    }

    // Check if the favorite belongs to the user
    if (favorite.userId !== user.id) {
      return c.json({ error: 'Not authorized' }, 403)
    }

    // Delete the favorite
    await db.delete(favorites).where(eq(favorites.id, favoriteId))
    logger.info(`User ${user.id} removed favorite ${favoriteId}`)
    return c.json({ message: 'Favorite removed successfully' }, 200)
  } catch (err) {
    logger.error('Error removing favorite', err)
    return c.json({ error: 'Failed to remove favorite' }, 500)
  }
})
