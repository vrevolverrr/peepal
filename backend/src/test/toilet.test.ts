import { describe, it, expect, beforeAll, afterAll, afterEach } from 'vitest'
import { app, db } from '../app'
import { users, toilets } from '../db/schema'
import { eq } from 'drizzle-orm'
import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'

interface ToiletResponse {
  toilet: {
    id: number
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
  report: {
    id: number
    reportCount?: number
  }
}

describe('Test Toilet API', () => {
  let testUser: any
  let authToken: string

  // Set up test database and create test user
  beforeAll(async () => {    
    // Create test user
    const passwordHash = await bcrypt.hash('testpassword', 10)
    const [ user ] = await db.insert(users).values({
      username: 'toiletuser',
      email: 'toilet@example.com',
      passwordHash,
      gender: 'male'
    }).returning()

    testUser = user
    authToken = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'your-secret-key')
  })

  // Clean up after tests
  afterAll(async () => {
    await db.delete(users).where(eq(users.email, 'toilet@example.com'))
  })

  describe('POST /api/toilets/create', () => {
    let createdToiletId: number

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

      expect(res.status).toBe(200)
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

  describe('PATCH /api/toilets/:id', () => {
    let testToiletId: number

    afterEach(async () => {
      if (testToiletId) {
        await db.delete(toilets).where(eq(toilets.id, testToiletId))
      }
    })

    beforeAll(async () => {
      const [ toilet ] = await db.insert(toilets).values({
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

      const res = await app.request(`/api/toilets/${testToiletId}`, {
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
      const res = await app.request('/api/toilets/999999', {
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

  describe('GET /api/toilets/:id', () => {
    let testToiletId: number

    afterEach(async () => {
      if (testToiletId) {
        await db.delete(toilets).where(eq(toilets.id, testToiletId))
      }
    })

    beforeAll(async () => {
      const [ toilet ] = await db.insert(toilets).values({
        name: 'Get Test Toilet',
        address: '789 Test Street',
        location: { x: 1.3521, y: 103.8198 }
      }).returning()
      testToiletId = toilet.id
    })

    it('should get toilet details', async () => {
      const res = await app.request(`/api/toilets/${testToiletId}`, {
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
      const res = await app.request('/api/toilets/999999', {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(404)
    })
  })

  describe('POST /api/toilets/report', () => {
    let testToiletId: number

    beforeAll(async () => {
      const [ toilet ] = await db.insert(toilets).values({
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
      const res = await app.request('/api/toilets/report', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ toiletId: testToiletId })
      })

      expect(res.status).toBe(200)
      const data = await res.json() as ReportResponse
      expect(data.report.reportCount).toBe(1)
    })

    it('should delete toilet after 3 reports', async () => {
      // Report twice more
      await app.request('/api/toilets/report', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ toiletId: testToiletId })
      })

      const finalReport = await app.request('/api/toilets/report', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ toiletId: testToiletId })
      })

      expect(finalReport.status).toBe(200)

      // Verify toilet is deleted
      const [ toilet ] = await db
        .select()
        .from(toilets)
        .where(eq(toilets.id, testToiletId))
        .limit(1)
      
      expect(toilet).toBeUndefined()
    })

    it('should return 400 for non-existent toilet', async () => {
      const res = await app.request('/api/toilets/report', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ toiletId: 999999 })
      })

      expect(res.status).toBe(400)
    })
  })
})
