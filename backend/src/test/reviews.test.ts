import { describe, it, expect, beforeAll, afterAll, afterEach, beforeEach, vi } from 'vitest'
import { app, db } from '../app'
import { users, toilets, reviews } from '../db/schema'
import { eq } from 'drizzle-orm'
import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { nanoid } from 'nanoid'

// Mock Minio client
vi.mock('minio', () => {
  return {
    Client: vi.fn().mockImplementation(() => ({}))
  }
})

interface ReviewResponse {
  review: {
    id: number
    toiletId: string
    userId: string
    rating: number
    reviewText?: string
    imageToken?: string
    createdAt: string
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

interface ReportMessageResponse {
  message: string
}

describe('Test Review API', () => {
  let testUser: any
  let authToken: string
  let testToilet: any
  let createdReviewId: number | undefined

  // Set up test database and create test user
  beforeAll(async () => {    
    // Generate unique test data with timestamps
    const timestamp = Date.now();
    const testUsername = `toiletuser_${timestamp}`;
    const testEmail = `toilet_${timestamp}@example.com`;
    
    // Create test user with UUID
    const passwordHash = await bcrypt.hash('testpassword', 10)
    
    // First check if the user already exists
    let user;
    const existingUsers = await db.select().from(users).where(eq(users.email, testEmail));
    
    if (existingUsers.length === 0) {
      const [newUser] = await db.insert(users).values({
        username: testUsername,
        email: testEmail,
        passwordHash,
        gender: 'male'
      }).returning();
      user = newUser;
    } else {
      user = existingUsers[0];
    }

    const [toilet] = await db.insert(toilets).values({
        id: nanoid(),
        name: 'Test Toilet',
        address: '123 Test Street',
        location: { x: 1.3521, y: 103.8198 },
        handicapAvail: true
      }).returning()
    
    testToilet = toilet
    testUser = user
    authToken = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'your-secret-key')
  })

  // Clean up after all tests
  afterAll(async () => {
    if (testUser && testUser.id) {
      await db.delete(reviews).where(eq(reviews.userId, testUser.id))
    }
    if (testToilet && testToilet.id) {
      await db.delete(toilets).where(eq(toilets.id, testToilet.id))
    }
    if (testUser && testUser.email) {
      await db.delete(users).where(eq(users.email, testUser.email))
    }
  })

  // test create review
  describe('POST /api/reviews/create', () => {
    afterEach(async () => {
      if (createdReviewId) {
        await db.delete(reviews).where(eq(reviews.id, createdReviewId))
      }
    })

    it('should create a review successfully', async () => {
      const reviewData = {
        toiletId: testToilet.id,
        rating: 4,
        reviewText: 'hello',
        imageToken: 'test-image-token'
      }

      const res = await app.request('/api/reviews/create', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(reviewData)
      })

      expect(res.status).toBe(201)
      const data = await res.json() as ReviewResponse
      expect(data.review).toBeDefined()
      expect(data.review.toiletId).toBe(reviewData.toiletId)
      expect(data.review.rating).toBe(reviewData.rating)
      expect(data.review.reviewText).toBe(reviewData.reviewText)
      expect(data.review.imageToken).toBe(reviewData.imageToken)
      expect(data.review.userId).toBe(testUser.id)
      expect(data.review.reportCount).toBe(0)
      
      // Store the created review ID for cleanup
      createdReviewId = data.review.id
    })

    it('should return 400 for invalid review rating', async () => {
      const invalidReviewData = {
        toiletId: testToilet.id,
        rating: 6,
        reviewText: 'hello',
        imageToken: 'test-image-token'
      }

      const res = await app.request('/api/reviews/create', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(invalidReviewData)
      })

      expect(res.status).toBe(400)
    })
  })

  // test update review
  describe('PATCH /api/reviews/edit/:reviewId', () => {
    let createdReviewId: number

    afterEach(async () => {
      if (createdReviewId) {
        await db.delete(reviews).where(eq(reviews.id, createdReviewId))
      }
    })

    beforeAll(async () => {
        const [ review ] = await db.insert(reviews).values({
          toiletId: testToilet.id,
          userId: testUser.id,
          rating: 3,
          reviewText: 'Good toilet'
        }).returning()
        createdReviewId = review.id
      })

    it('should update a review successfully', async () => {
      const updateData = {
        rating: 4,
        reviewText: 'Updated review'
      }

      const res = await app.request(`/api/reviews/edit/${createdReviewId}`, {
        method: 'PATCH',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(updateData)
      })

      expect(res.status).toBe(200)
      const data = await res.json() as ReviewResponse
      expect(data.review.rating).toBe(updateData.rating)
      expect(data.review.reviewText).toBe(updateData.reviewText)
    })

    it('should return 404 for non-existent review', async () => {
      const updateData = {
        rating: 4,
        reviewText: 'Updated review'
      }

      const res = await app.request('/api/reviews/edit/999999', {
        method: 'PATCH',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(updateData)
      })

      expect(res.status).toBe(404)
    })
  })

  // test fetch reviews
  describe('GET /api/reviews/toilet/:toiletId', () => {
    let createdReviewId: number

    beforeEach(async () => {
      // Ensure we're using the correct types for IDs
      const [ review ] = await db.insert(reviews).values({
        toiletId: testToilet.id,
        userId: testUser.id,
        rating: 3,
        reviewText: 'Good toilet'
      }).returning()
      createdReviewId = review.id
    })

    afterEach(async () => {
      if (createdReviewId) {
        await db.delete(reviews).where(eq(reviews.id, createdReviewId))
      }
    })

    it('should get reviews for a toilet with default sorting', async () => {
      const res = await app.request(`/api/reviews/toilet/${testToilet.id}?offset=0&sort=date&order=desc`, {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(200)
      const data = await res.json() as { reviews: any[] }

      expect(data.reviews).toBeDefined()
      expect(data.reviews.length).toBe(1)
      expect(data.reviews[0].id).toBe(createdReviewId)
      expect(data.reviews[0].toiletId).toBe(testToilet.id)
      expect(data.reviews[0].username).toBeDefined()
    })

    it('should get reviews sorted by rating', async () => {
      const res = await app.request(`/api/reviews/toilet/${testToilet.id}?offset=0&sort=rating&order=asc`, {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(200)
      const data = await res.json() as { reviews: any[] }
      expect(data.reviews).toBeDefined()
      expect(data.reviews[0].rating).toBeDefined()
    })

    it('should return 404 for non-existent toilet', async () => {
      const res = await app.request('/api/reviews/toilet/999999', {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(404)
    })
  })

  // test report review
  describe('POST /api/reviews/report/:reviewId', () => {
    let createdReviewId: number

    beforeAll(async () => {
      // Ensure we're using the correct types for IDs
      const [ review ] = await db.insert(reviews).values({
        toiletId: testToilet.id,
        userId: testUser.id,
        rating: 3,
        reviewText: 'Good toilet'
      }).returning()
      createdReviewId = review.id
    })

    afterAll(async () => {
      await db.delete(reviews).where(eq(reviews.id, createdReviewId))
    })

    it('should increment report count', async () => {
      const res = await app.request(`/api/reviews/report/${createdReviewId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
      })

      expect(res.status).toBe(200)
      
      // Verify report count is incremented
      const [review] = await db
        .select()
        .from(reviews)
        .where(eq(reviews.id, createdReviewId))
        .limit(1)
      expect(review.reportCount).toBe(1)
    })

    it('should delete review after 3 reports', async () => {
      // First, verify the review exists and has report count of 1 from previous test
      let [reviewBefore] = await db
        .select()
        .from(reviews)
        .where(eq(reviews.id, createdReviewId))
        .limit(1)
      
      expect(reviewBefore).toBeDefined()
      expect(reviewBefore.reportCount).toBe(1)
      
      // Report a second time
      const secondReport = await app.request(`/api/reviews/report/${createdReviewId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
      })
      
      expect(secondReport.status).toBe(200)
      
      // Report a third time - this should trigger deletion
      const finalReport = await app.request(`/api/reviews/report/${createdReviewId}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
      })

      expect(finalReport.status).toBe(200)
      const data = await finalReport.json() as ReportMessageResponse
      expect(data.message).toBe('Review reported and deleted after reaching threshold')

      // Verify review is deleted
      const [reviewAfter] = await db
        .select()
        .from(reviews)
        .where(eq(reviews.id, createdReviewId))
        .limit(1)
      
      expect(reviewAfter).toBeUndefined()
    })

    it('should return 404 for non-existent review', async () => {
      const res = await app.request('/api/reviews/report/999999', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
      })

      expect(res.status).toBe(404)
    })
  })

  // test delete review
  describe('DELETE /api/reviews/:id', () => {
    let testReviewId: number

    beforeEach(async () => {
      // Ensure we're using the correct types for IDs
      const [review] = await db.insert(reviews).values({
        toiletId: testToilet.id,
        userId: testUser.id,
        rating: 3,
        reviewText: 'Test review'
      }).returning()
      testReviewId = review.id
    })

    afterEach(async () => {
      await db.delete(reviews).where(eq(reviews.toiletId, testToilet.id))
    })

    it('should delete a review', async () => {
      const res = await app.request(`/api/reviews/delete/${testReviewId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
      })

      expect(res.status).toBe(200)
      const [deletedReview] = await db
        .select()
        .from(reviews)
        .where(eq(reviews.id, testReviewId))
        .limit(1)
      expect(deletedReview).toBeUndefined()
    })

    it('should return 404 for non-existent review', async () => {
      const res = await app.request('/api/reviews/999999', {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
      })

      expect(res.status).toBe(404)
    })

    it('should require authentication', async () => {
      const res = await app.request(`/api/reviews/delete/${testReviewId}`, {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
      })

      expect(res.status).toBe(401)
    })
  })
})