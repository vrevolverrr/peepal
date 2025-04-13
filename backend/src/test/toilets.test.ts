import { describe, it, expect, beforeAll, afterAll, afterEach, vi } from 'vitest'
import { app, db } from '../app'
import { users, toilets } from '../db/schema'
import { eq, sql } from 'drizzle-orm'
import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { nanoid } from 'nanoid'

// Mock Minio client
vi.mock('minio', () => {
  return {
    Client: vi.fn().mockImplementation(() => ({
    }))
  }
})

interface ToiletResponse {
  toilet: {
    id: string
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
    reportCount?: number
  }
}

interface ErrorResponse {
  error: string
}

interface ReportResponse {
  reportCount?: number
  deleted?: boolean
}

describe('Test Toilet API', () => {
  let testUser: any
  let authToken: string

  // Set up test database and create test user
  beforeAll(async () => {    
    // Generate unique test data with timestamps
    const timestamp = Date.now();
    const testUsername = `toiletuser_${timestamp}`;
    const testEmail = `toilet_${timestamp}@example.com`;
    
    // Create test user
    const passwordHash = await bcrypt.hash('testpassword', 10)
    
    // First check if the user already exists by email or username
    let user;
    const existingUsersByEmail = await db.select().from(users).where(eq(users.email, testEmail));
    const existingUsersByUsername = await db.select().from(users).where(eq(users.username, testUsername));
    
    if (existingUsersByEmail.length === 0 && existingUsersByUsername.length === 0) {
      try {
        const [newUser] = await db.insert(users).values({
          username: testUsername,
          email: testEmail,
          passwordHash,
          gender: 'male'
        }).returning();
        user = newUser;
      } catch (error) {
        // If there's a conflict, generate a new username with more entropy
        const moreUniqueUsername = `toiletuser_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
        const moreUniqueEmail = `toilet_${Date.now()}_${Math.random().toString(36).substring(2, 7)}@example.com`;
        
        const [newUser] = await db.insert(users).values({
          username: moreUniqueUsername,
          email: moreUniqueEmail,
          passwordHash,
          gender: 'male'
        }).returning();
        user = newUser;
      }
    } else if (existingUsersByEmail.length > 0) {
      user = existingUsersByEmail[0];
    } else {
      user = existingUsersByUsername[0];
    }

    testUser = user
    authToken = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'your-secret-key')
  })

  // Clean up after tests
  afterAll(async () => {
    if (testUser && testUser.email) {
      await db.delete(users).where(eq(users.email, testUser.email))
    }
  })

  describe('POST /api/toilets/create', () => {
    let createdToiletId: string

    afterEach(async () => {
      if (createdToiletId) {
        await db.delete(toilets).where(eq(toilets.id, createdToiletId))
      }
    })

    it('should create a new toilet with valid data', async () => {
      const toiletData = {
        name: 'Test Toilet',
        address: '123 Test Street',
        location: {
          x: 1.3521,
          y: 103.8198
        },
        handicapAvail: true,
        bidetAvail: false,
        showerAvail: true,
        sanitiserAvail: true
      }

      const res = await app.request('/api/toilets/create', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(toiletData)
      })

      expect(res.status).toBe(201)
      const data = await res.json() as ToiletResponse
      expect(data.toilet).toBeDefined()
      expect(data.toilet.name).toBe(toiletData.name)
      expect(data.toilet.address).toBe(toiletData.address)
      expect(data.toilet.location).toEqual(toiletData.location)
      createdToiletId = data.toilet.id
    })

    it('should reject invalid location coordinates', async () => {
      const invalidData = {
        name: 'Test Toilet',
        address: '123 Test Street',
        location: {
          x: 'invalid',
          y: 103.8198
        }
      }

      const res = await app.request('/api/toilets/create', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(invalidData)
      })

      expect(res.status).toBe(400)
    })
  })

  describe('PATCH /api/toilets/details/:id', () => {
    let testToiletId: string

    afterEach(async () => {
      if (testToiletId) {
        await db.delete(toilets).where(eq(toilets.id, testToiletId))
      }
    })

    beforeAll(async () => {
      const [ toilet ] = await db.insert(toilets).values({
        id: nanoid(),
        name: 'Update Test Toilet',
        address: '456 Test Street',
        location: { x: 1.3521, y: 103.8198 },
        handicapAvail: true
      }).returning()
      testToiletId = toilet.id
    })

    it('should update toilet details', async () => {
      const updateData = {
        name: 'Updated Toilet Name',
        handicapAvail: false
      }

      const res = await app.request(`/api/toilets/details/${testToiletId}?id=${testToiletId}`, {
        method: 'PATCH',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(updateData)
      })

      expect(res.status).toBe(200)
      const data = await res.json() as ToiletResponse
      expect(data.toilet.name).toBe(updateData.name)
      expect(data.toilet.handicapAvail).toBe(updateData.handicapAvail)
    })

    it('should return 404 for non-existent toilet', async () => {
      const res = await app.request('/api/toilets/details/non-existent-id?id=non-existent-id', {
        method: 'PATCH',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ name: 'New Name' })
      })

      expect(res.status).toBe(404)
    })
  })

  describe('GET /api/toilets/detals/:id', () => {
    let testToiletId: string

    afterEach(async () => {
      if (testToiletId) {
        await db.delete(toilets).where(eq(toilets.id, testToiletId))
      }
    })

    beforeAll(async () => {
      const [ toilet ] = await db.insert(toilets).values({
        id: nanoid(),
        name: 'Get Test Toilet',
        address: '789 Test Street',
        location: { x: 1.3521, y: 103.8198 }
      }).returning()
      testToiletId = toilet.id
    })

    it('should get toilet details', async () => {
      const res = await app.request(`/api/toilets/details/${testToiletId}?id=${testToiletId}`, {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(200)
      const data = await res.json() as ToiletResponse
      expect(data.toilet).toBeDefined()
      expect(data.toilet.id).toBe(testToiletId)
    })

    it('should return 404 for non-existent toilet', async () => {
      const res = await app.request('/api/toilets/details/non-existent-id?id=non-existent-id', {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(404)
    })
  })

  describe('POST /api/toilets/report/:id', () => {
    let testToiletId: string

    beforeAll(async () => {
      const [ toilet ] = await db.insert(toilets).values({
        id: nanoid(),
        name: 'Report Test Toilet',
        address: '321 Test Street',
        location: { x: 1.3521, y: 103.8198 },
      }).returning()
      testToiletId = toilet.id
    })

    afterAll(async () => {
      await db.delete(toilets).where(eq(toilets.id, testToiletId))
    })

    it('should increment report count', async () => {
      const res = await app.request(`/api/toilets/report/${testToiletId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      expect(res.status).toBe(200)
      const data = await res.json() as ReportResponse
      expect(data.deleted).toBe(false)

      // Verify toilet report count is incremented
      const [ toilet ] = await db
        .select()
        .from(toilets)
        .where(eq(toilets.id, testToiletId))
        .limit(1)
          
      expect(toilet!.reportCount).toBe(1)
    })

    it('should delete toilet after 3 reports', async () => {
      // Report twice more
      await app.request(`/api/toilets/report/${testToiletId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      const finalReport = await app.request(`/api/toilets/report/${testToiletId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      expect(finalReport.status).toBe(200)
      const data = await finalReport.json() as ReportResponse
      expect(data.deleted).toBe(true)

      // Verify toilet is deleted
      const [ toilet ] = await db
        .select()
        .from(toilets)
        .where(eq(toilets.id, testToiletId))
        .limit(1)
      
      expect(toilet).toBeUndefined()
    })

    it('should return 400 for non-existent toilet', async () => {
      const res = await app.request('/api/toilets/report/999999', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      expect(res.status).toBe(404)
    })
  })

  describe('GET /api/toilets/nearby', () => {
    let testToiletIds: string[] = []

    beforeAll(async () => {
      // Create multiple test toilets with different locations
      // Note: In PostgreSQL with PostGIS, we need to ensure the location data is properly formatted
      // The API expects longitude (x) and latitude (y) as numbers
      const toiletsData = [
        {
          id: nanoid(),
          name: 'Nearby Test Toilet 1',
          address: '123 Nearby Street',
          location: sql`ST_SetSRID(ST_MakePoint(103.8198, 1.3521), 4326)`,
          handicapAvail: true,
          bidetAvail: false
        },
        {
          id: nanoid(),
          name: 'Nearby Test Toilet 2',
          address: '456 Nearby Avenue',
          location: sql`ST_SetSRID(ST_MakePoint(103.8220, 1.3540), 4326)`,
          handicapAvail: false,
          bidetAvail: true
        },
        {
          id: nanoid(),
          name: 'Far Test Toilet',
          address: '789 Far Road',
          location: sql`ST_SetSRID(ST_MakePoint(103.9000, 1.4000), 4326)`,
          handicapAvail: true,
          bidetAvail: true
        }
      ]

      for (const toiletData of toiletsData) {
        // Need to use direct SQL for inserting with PostGIS functions
        const [toilet] = await db.insert(toilets).values({
          id: toiletData.id,
          name: toiletData.name,
          address: toiletData.address,
          location: toiletData.location,
          handicapAvail: toiletData.handicapAvail,
          bidetAvail: toiletData.bidetAvail
        }).returning()
        testToiletIds.push(toilet.id)
      }
    })

    afterAll(async () => {
      // Clean up test toilets
      for (const id of testToiletIds) {
        await db.delete(toilets).where(eq(toilets.id, id))
      }
    })

    it('should return nearby toilets ordered by distance', async () => {
      // Use coordinates close to the first two test toilets
      // The validator expects string values for latitude and longitude
      const res = await app.request('/api/toilets/nearby?latitude=1.3530&longitude=103.8210', {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(200)
      const data = await res.json() as { toilets: any[] }
      
      expect(data.toilets).toBeDefined()
      expect(data.toilets.length).toBeGreaterThan(0)
      
      // Verify toilets are returned and have distance property
      expect(data.toilets[0]).toHaveProperty('id')
      expect(data.toilets[0]).toHaveProperty('name')
      expect(data.toilets[0]).toHaveProperty('distance')
      
      // Check if toilets are ordered by distance (closest first)
      if (data.toilets.length > 1) {
        expect(Number(data.toilets[0].distance)).toBeLessThanOrEqual(Number(data.toilets[1].distance))
      }
    })

    it('should handle invalid coordinates gracefully', async () => {
      const res = await app.request('/api/toilets/nearby?latitude=invalid&longitude=invalid', {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      // Should return an error response
      expect(res.status).not.toBe(200)
    })
  })
})
