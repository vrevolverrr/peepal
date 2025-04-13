import { describe, it, expect, beforeAll, beforeEach, afterAll, afterEach, vi } from 'vitest'
import { app, db } from '../app'
import { users, toilets, favorites } from '../db/schema'
import { eq, inArray } from 'drizzle-orm'
import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { nanoid } from 'nanoid'

// Mock Minio client
vi.mock('minio', () => {
  return {
    Client: vi.fn().mockImplementation(() => ({}))
  }
})

interface FavoriteResponse {
  favorite: {
    id: number
    userId: string
    toiletId: string // Update to string since toilet IDs are text
  }
}

interface FavoritesListResponse {
  favorites: Array<{
    toiletId: string
    createdAt: string
  }>
}

interface ErrorResponse {
  error: string
}

describe('Test Favorites API', () => {
  let testUser: any
  let authToken: string
  let testToiletId: string

  beforeAll(async () => {
    // Generate unique test data with timestamps
    const timestamp = Date.now();
    const testUsername = `favorites_test_user_${timestamp}`;
    const testEmail = `favorites_${timestamp}@example.com`;
    
    // Create test user
    const passwordHash = await bcrypt.hash('password123', 10)
    
    // First check if the user already exists
    let user;
    const existingUsers = await db.select().from(users).where(eq(users.email, testEmail));
    
    if (existingUsers.length === 0) {
      const [newUser] = await db.insert(users).values({
        username: testUsername,
        email: testEmail,
        passwordHash
      }).returning();
      user = newUser;
    } else {
      user = existingUsers[0];
    }
    testUser = user

    authToken = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'your-secret-key')

    // Create test toilet
    const [toilet] = await db.insert(toilets).values({
      id: nanoid(), // Add ID field using nanoid
      name: 'Favorites Test Toilet',
      address: '123 Test Street',
      location: { x: 1.3521, y: 103.8198 },
      handicapAvail: true,
      bidetAvail: true
    }).returning()
    testToiletId = toilet.id
  })

  // Clean up after tests
  afterAll(async () => {
    if (testToiletId) {
      await db.delete(toilets).where(eq(toilets.id, testToiletId))
    }
    if (testUser && testUser.email) {
      await db.delete(users).where(eq(users.email, testUser.email))
    }
    if (testUser && testUser.id) {
      await db.delete(favorites).where(eq(favorites.userId, testUser.id))
    }
  })

  describe('POST /api/favorites/add', () => {
    afterEach(async () => {
      await db.delete(favorites).where(eq(favorites.userId, testUser.id))
    })

    it('should add a toilet to favorites', async () => {
      const res = await app.request(`/api/favorites/add/${testToiletId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      expect(res.status).toBe(201)
      const data = await res.json() as FavoriteResponse
      expect(data.favorite).toBeDefined()
      expect(data.favorite.toiletId).toBe(testToiletId)
      expect(data.favorite.userId).toBe(testUser.id)
    })

    it('should reject duplicate favorites', async () => {
      // Add first time
      await app.request(`/api/favorites/add/${testToiletId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      // Try to add again
      const res = await app.request(`/api/favorites/add/${testToiletId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      expect(res.status).toBe(400)
      const data = await res.json() as ErrorResponse
      expect(data.error).toBe('Toilet is already in favorites')
    })

    it('should require authentication', async () => {
      const res = await app.request(`/api/favorites/add/${testToiletId}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      })

      expect(res.status).toBe(401)
    })
  })

  describe('GET /api/favorites/me', () => {
    const testToilets = [
      { 
        id: 'test-toilet-1', 
        name: 'Toilet A', 
        address: '123 Street A',
        location: { x: 1.3521, y: 103.8198 },
        handicapAvail: true,
        bidetAvail: true,
        rating: '4.5',
        reportCount: 0
      },
      { 
        id: 'test-toilet-2', 
        name: 'Toilet B', 
        address: '123 Street B',
        location: { x: 1.3522, y: 103.8199 },
        handicapAvail: true,
        bidetAvail: true,
        rating: '3.5',
        reportCount: 0
      },
      { 
        id: 'test-toilet-3', 
        name: 'Toilet C', 
        address: '123 Street C',
        location: { x: 1.3523, y: 103.8200 },
        handicapAvail: true,
        bidetAvail: true,
        rating: '5.0',
        reportCount: 0
      },
      { 
        id: 'test-toilet-4', 
        name: 'Toilet D', 
        address: '123 Street D',
        location: { x: 1.3524, y: 103.8201 },
        handicapAvail: true,
        bidetAvail: true,
        rating: '2.5',
        reportCount: 0
      }
    ]

    beforeAll(async () => {
      // Insert test toilets
      for (const toilet of testToilets) {
        await db.insert(toilets).values({
          id: toilet.id,
          name: toilet.name,
          address: toilet.address,
          location: toilet.location,
          handicapAvail: toilet.handicapAvail,
          bidetAvail: toilet.bidetAvail,
          rating: toilet.rating,
          reportCount: toilet.reportCount
        })
      }

      // Add favorites with different creation times
      for (const toilet of testToilets) {
        await db.insert(favorites).values({
          userId: testUser.id,
          toiletId: toilet.id
        })
        // Wait a bit to ensure different creation times
        await new Promise(resolve => setTimeout(resolve, 100))
      }
    })

    afterAll(async () => {
      // Clean up test toilets and favorites
      await db.delete(favorites).where(eq(favorites.userId, testUser.id))
      await db.delete(toilets).where(inArray(toilets.id, testToilets.map(t => t.id)))
    })

    it('should list user favorites with correct format', async () => {
      const res = await app.request('/api/favorites/me', {
        headers: { 'Authorization': `Bearer ${authToken}` }
      })

      expect(res.status).toBe(200)
      const data = await res.json() as FavoritesListResponse
      expect(data.favorites).toHaveLength(testToilets.length)
      
      // Verify each favorite has the correct structure
      for (const favorite of data.favorites) {
        expect(favorite).toHaveProperty('toiletId')
        expect(favorite).toHaveProperty('createdAt')
      }
    })

    it('should return favorites sorted by creation time (desc)', async () => {
      const res = await app.request('/api/favorites/me', {
        headers: { 'Authorization': `Bearer ${authToken}` }
      })

      expect(res.status).toBe(200)
      const data = await res.json() as FavoritesListResponse
      expect(data.favorites).toHaveLength(testToilets.length)
      
      // Verify sorting by creation time (desc)
      for (let i = 0; i < data.favorites.length - 1; i++) {
        const currentTimestamp = new Date(data.favorites[i].createdAt).getTime()
        const nextTimestamp = new Date(data.favorites[i + 1].createdAt).getTime()
        expect(currentTimestamp).toBeGreaterThan(nextTimestamp)
      }
    })

    it('should require authentication', async () => {
      const res = await app.request('/api/favorites/me')
      expect(res.status).toBe(401)
    })
  })

  describe('DELETE /api/favorites/remove', () => {
    beforeEach(async () => {
      // Add a favorite before each test
      await db.insert(favorites).values({
        userId: testUser.id,
        toiletId: testToiletId
      })
    })

    afterEach(async () => {
      await db.delete(favorites).where(eq(favorites.userId, testUser.id))
    })

    it('should remove a favorite', async () => {
      const res = await app.request(`/api/favorites/remove/${testToiletId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      expect(res.status).toBe(200)
      const [remaining] = await db
        .select()
        .from(favorites)
        .where(eq(favorites.toiletId, testToiletId))
      expect(remaining).toBeUndefined()
    })

    it('should return 400 for non-existent favorite', async () => {
      const res = await app.request('/api/favorites/remove/non-existent-id', {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      expect(res.status).toBe(400)
    })

    it('should require authentication', async () => {
      const res = await app.request(`/api/favorites/remove/${testToiletId}`, {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' }
      })

      expect(res.status).toBe(401)
    })
  })
})
