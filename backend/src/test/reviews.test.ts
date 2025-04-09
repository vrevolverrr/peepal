import { describe, it, expect, beforeAll, afterAll, afterEach, beforeEach } from 'vitest'
import { app, db } from '../app'
import { users, toilets, reviews } from '../db/schema'
import { eq } from 'drizzle-orm'
import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'

interface ReviewResponse {
  review: {
    id: number
    toiletId: number
    userId: number
    rating: number
    reviewText?: string
    imageUrl?: string
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
    // Create test user
    const passwordHash = await bcrypt.hash('testpassword', 10)
    const [ user ] = await db.insert(users).values({
    username: 'toiletuser',
    email: 'toilet@example.com',
    passwordHash,
    gender: 'male'
    }).returning()

    const [toilet] = await db.insert(toilets).values({
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
    await db.delete(reviews).where(eq(reviews.userId, testUser.id))
    await db.delete(toilets).where(eq(toilets.id, testToilet.id))
    await db.delete(users).where(eq(users.email, 'toilet@example.com'))
  })

  // test create review
  describe('POST /api/reviews', () => {
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
        imageUrl: 'https://test.image.com'  // Valid URL format
      }

      const res = await app.request('/api/reviews', {
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
      expect(data.review.imageUrl).toBe(reviewData.imageUrl)
      expect(data.review.userId).toBe(testUser.id)
      expect(data.review.reportCount).toBe(0)
      
      // Store the created review ID for cleanup
      createdReviewId = data.review.id
    })

    it('should return 400 for invalid review data', async () => {
      const invalidReviewData = {
        toiletId: testToilet.id,
        rating: 6,  // Invalid rating (should be 1-5)
        reviewText: 'hello',
        imageUrl: 'not-a-url'  // Invalid URL
      }

      const res = await app.request('/api/reviews', {
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
  describe('PATCH /api/reviews/:id', () => {
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

      const res = await app.request(`/api/reviews/${createdReviewId}`, {
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

      const res = await app.request('/api/reviews/999999', {
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
  describe('GET /api/reviews/toilet/:toilet_id', () => {
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

    it('should get reviews for a toilet', async () => {
      const res = await app.request(`/api/reviews/toilet?toiletId=${testToilet.id}`, {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(200)
      const data = await res.json() as { reviews: ReviewResponse[] }
      expect(data.reviews).toBeDefined()
      expect(data.reviews.length).toBe(1)
      expect(data.reviews[0].review.id).toBe(createdReviewId)
    })

    it('should return 404 for non-existent toilet', async () => {
      const res = await app.request('/api/reviews/toilet?toiletId=999999', {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(404)
    })
  })

  describe('POST /api/reviews/:id/report', () => {
    let createdReviewId: number

    beforeAll(async () => {
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
      const res = await app.request(`/api/reviews/${createdReviewId}/report`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ reviewId: createdReviewId })
      })

      expect(res.status).toBe(200)
      const data = await res.json() as ReportMessageResponse
      expect(data.message).toBe('Review reported')
    })

    it('should delete review after 3 reports', async () => {
      // Report twice more
      await app.request(`/api/reviews/${createdReviewId}/report`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ reviewId: createdReviewId })
      })

      const finalReport = await app.request(`/api/reviews/${createdReviewId}/report`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ reviewId: createdReviewId })
      })

      expect(finalReport.status).toBe(200)
      const data = await finalReport.json() as ReportMessageResponse
      expect(data.message).toBe('Review reported and deleted after reaching threshold')

      // Verify review is deleted
      const [ review ] = await db
        .select()
        .from(reviews)
        .where(eq(reviews.id, createdReviewId))
        .limit(1)
      
      expect(review).toBeUndefined()
    })

    it('should return 404 for non-existent review', async () => {
      const res = await app.request(`/api/reviews/999999/report`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ reviewId: 999999 })
      })

      expect(res.status).toBe(404)
    })
  })

  describe('DELETE /api/reviews/:id', () => {
    let testReviewId: number

    beforeEach(async () => {
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
      const res = await app.request(`/api/reviews/${testReviewId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ reviewId: testReviewId })
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
        body: JSON.stringify({ reviewId: 999999 })
      })

      expect(res.status).toBe(404)
    })

    it('should require authentication', async () => {
      const res = await app.request(`/api/reviews/${testReviewId}`, {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reviewId: testReviewId })
      })

      expect(res.status).toBe(401)
    })
  })
})