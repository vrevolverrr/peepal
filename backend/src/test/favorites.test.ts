import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { app, db } from '../app'
import { favorites, users, toilets } from '../db/schema'
import { eq } from 'drizzle-orm'
import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'

interface FavoriteResponse {
  favorite: {
    id: number
    userId: string
    toiletId: number
    createdAt: string
  }
}

interface FavoritesListResponse {
  favorites: Array<{
    id: number
    userId: string
    toiletId: number
    createdAt: string
  }>
}

interface ErrorResponse {
  error: string
}

interface MessageResponse {
  message: string
}

describe('Test Favorites API', () => {
  let testUser: any
  let authToken: string
  let testToilet: any
  let testFavoriteId: number

  // Set up test database and create test user
  beforeAll(async () => {
    // Create test user
    const passwordHash = await bcrypt.hash('testpassword', 10)
    const [user] = await db.insert(users).values({
      username: 'favoritetester',
      email: 'favorite@example.com',
      passwordHash,
      gender: 'male'
    }).returning()

    testUser = user
    authToken = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'your-secret-key')

    // Create test toilet
    const [toilet] = await db.insert(toilets).values({
      name: 'Test Toilet',
      address: '123 Test St',
      location: {
        x: 51.5074,  // Longitude (example: London)
        y: 0.1278,   // Latitude (example: London)
      },
      crowdLevel: 1,
      rating: '0.00',
      toiletAvail: true,
      handicapAvail: false,
      bidetAvail: true,
      showerAvail: false,
      sanitiserAvail: true
    }).returning()

    testToilet = toilet
  })

  // Clean up test data after all tests
  afterAll(async () => {
    await db.delete(favorites).where(eq(favorites.userId, testUser.id))
    await db.delete(users).where(eq(users.id, testUser.id))
    await db.delete(toilets).where(eq(toilets.id, testToilet.id))
  })

  describe('POST /api/favorites', () => {
    it('should add a toilet to favorites', async () => {
      const res = await app.request('/api/favorites', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          toiletId: testToilet.id
        })
      })

      expect(res.status).toBe(201)
      const data = await res.json() as FavoriteResponse
      expect(data.favorite).toBeDefined()
      expect(data.favorite.userId).toBe(testUser.id)
      expect(data.favorite.toiletId).toBe(testToilet.id)
      testFavoriteId = data.favorite.id
    })

    it('should not allow adding same toilet twice', async () => {
      const res = await app.request('/api/favorites', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          toiletId: testToilet.id
        })
      })

      expect(res.status).toBe(400)
      const data = await res.json() as ErrorResponse
      expect(data.error).toBe('Toilet is already in favorites')
    })
  })

  describe('GET /api/favorites/user/:user_id', () => {
    it('should get user favorites', async () => {
      const res = await app.request(`/api/favorites/user/${testUser.id}`, {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(200)
      const data = await res.json() as FavoritesListResponse
      expect(Array.isArray(data.favorites)).toBe(true)
      expect(data.favorites.length).toBeGreaterThan(0)
      expect(data.favorites[0].userId).toBe(testUser.id)
    })

    it('should not allow viewing other user\'s favorites', async () => {
      const passwordHash = await bcrypt.hash('otherpassword', 10)
      const [otherUser] = await db.insert(users).values({
        username: 'otheruser' + Date.now(),
        email: 'other' + Date.now() + '@example.com',
        passwordHash
      }).returning()

      const res = await app.request(`/api/favorites/user/${otherUser.id}`, {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(403)
      const data = await res.json() as ErrorResponse
      expect(data.error).toBe('Not authorized')

      // Clean up other user
      await db.delete(users).where(eq(users.id, otherUser.id))
    })
  })

  describe('DELETE /api/favorites/:id', () => {
    it('should remove a favorite', async () => {
      const res = await app.request(`/api/favorites/${testFavoriteId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(200)
      const data = await res.json() as MessageResponse
      expect(data.message).toBe('Favorite removed successfully')

      // Verify favorite is removed
      const [removed] = await db
        .select()
        .from(favorites)
        .where(eq(favorites.id, testFavoriteId))
      expect(removed).toBeUndefined()
    })

    it('should not allow removing other user\'s favorite', async () => {
      // Create another user and their favorite
      const passwordHash = await bcrypt.hash('otherpassword', 10)
      const [otherUser] = await db.insert(users).values({
        username: 'otheruser' + Date.now(),
        email: 'other' + Date.now() + '@example.com',
        passwordHash
      }).returning()

      const [otherFavorite] = await db.insert(favorites).values({
        userId: otherUser.id,
        toiletId: testToilet.id
      }).returning()

      // Try to remove other user's favorite
      const res = await app.request(`/api/favorites/${otherFavorite.id}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(403)
      const data = await res.json() as ErrorResponse
      expect(data.error).toBe('Not authorized')

      // Clean up other user and their favorite
      await db.delete(favorites).where(eq(favorites.id, otherFavorite.id))
      await db.delete(users).where(eq(users.id, otherUser.id))
    })
  })
})
