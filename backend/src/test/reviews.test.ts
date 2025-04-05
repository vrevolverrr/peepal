import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { app, db } from '../app'
import { reviews, users, toilets } from '../db/schema'
import { eq } from 'drizzle-orm'
import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'

interface ReviewResponse {
  review: {
    id: number
    toiletId: number
    userId: string
    rating: number
    reviewText?: string
    imageUrl?: string
    reportCount?: number
    createdAt: string
  }
}

interface ReviewsListResponse {
  reviews: Array<{
    id: number
    toiletId: number
    userId: string
    rating: number
    reviewText?: string
    imageUrl?: string
    reportCount?: number
    createdAt: string
  }>
}

interface ErrorResponse {
  error: string
}

interface MessageResponse {
  message: string
}

describe('Test Reviews API', () => {
  let testUser: any
  let authToken: string
  let testReviewId: number
  let testToilet: any

  // Set up test database and create test user
  beforeAll(async () => {
    // Create test user
    const passwordHash = await bcrypt.hash('testpassword', 10)
    const [user] = await db.insert(users).values({
      username: 'reviewtester',
      email: 'reviewer@example.com',
      passwordHash,
      gender: 'male'
    }).returning()

    testUser = user
    authToken = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'your-secret-key')

    // Create test toilet
    const [toilet] = await db.insert(toilets).values({
      name: 'Test Toilet',
      address: '123 Test St',
      location:{
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

    // Create some test reviews
    await db.insert(reviews).values([
      {
        toiletId: testToilet.id,
        userId: user.id,
        rating: 4,
        reviewText: 'Great toilet!',
        imageUrl: 'https://example.com/image1.jpg',
        createdAt: new Date(Date.now() - 1000)
      },
      {
        toiletId: testToilet.id,
        userId: user.id,
        rating: 5,
        reviewText: 'Amazing toilet!',
        imageUrl: 'https://example.com/image2.jpg',
        createdAt: new Date()
      }
    ])
  })

  // Clean up test data after all tests
  afterAll(async () => {
    await db.delete(reviews).where(eq(reviews.userId, testUser.id))
    await db.delete(users).where(eq(users.id, testUser.id))
    await db.delete(toilets).where(eq(toilets.id, testToilet.id))
  })

  describe('POST /api/reviews', () => {
    it('should create a new review', async () => {
      const res = await app.request('/api/reviews', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          toiletId: testToilet.id,
          rating: 4,
          reviewText: 'Great toilet!',
          imageUrl: 'https://example.com/image.jpg'
        })
      })

      expect(res.status).toBe(201)
      const data = await res.json() as ReviewResponse
      expect(data.review).toBeDefined()
      expect(data.review.toiletId).toBe(testToilet.id)
      expect(data.review.rating).toBe(4)
      expect(data.review.reviewText).toBe('Great toilet!')
      expect(data.review.imageUrl).toBe('https://example.com/image.jpg')
      expect(data.review.userId).toBe(testUser.id)

      testReviewId = data.review.id // Save for later tests
    })

    it('should reject invalid rating', async () => {
      const res = await app.request('/api/reviews', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          toiletId: testToilet.id,
          rating: 6, // Invalid rating > 5
          reviewText: 'Invalid rating!'
        })
      })

      expect(res.status).toBe(400)
      const data = await res.json() as ErrorResponse
      expect(data.error).toBe('Invalid input')
    })
  })

  describe('GET /api/reviews/toilet/:toilet_id', () => {
    it('should get reviews for a toilet sorted by date', async () => {
      const res = await app.request(`/api/reviews/toilet/${testToilet.id}`, {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })
      
      expect(res.status).toBe(200)
      const data = await res.json() as ReviewsListResponse
      expect(Array.isArray(data.reviews)).toBe(true)
      expect(data.reviews.length).toBeGreaterThan(0)
      expect(data.reviews[0].toiletId).toBe(testToilet.id)
    })

    it('should get reviews sorted by rating', async () => {
      const res = await app.request(`/api/reviews/toilet/${testToilet.id}?sort=rating`, {
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })
      
      expect(res.status).toBe(200)
      const data = await res.json() as ReviewsListResponse
      expect(Array.isArray(data.reviews)).toBe(true)
      if (data.reviews.length > 1) {
        expect(data.reviews[0].rating).toBeGreaterThanOrEqual(data.reviews[1].rating)
      }
    })
  })

  describe('PUT /api/reviews/:id', () => {
    it('should update review text and rating', async () => {
      const res = await app.request(`/api/reviews/${testReviewId}`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          rating: 5,
          reviewText: 'Updated review text'
        })
      })

      expect(res.status).toBe(200)
      const data = await res.json() as ReviewResponse
      expect(data.review.rating).toBe(5)
      expect(data.review.reviewText).toBe('Updated review text')
    })

    it('should not allow updating another user\'s review', async () => {
      // Create another user and their auth token
      const passwordHash = await bcrypt.hash('otherpassword', 10)
      const [otherUser] = await db.insert(users).values({
        username: 'otheruser' + Date.now(), // Make username unique
        email: 'other' + Date.now() + '@example.com', // Make email unique
        passwordHash
      }).returning()
      const otherToken = jwt.sign({ id: otherUser.id }, process.env.JWT_SECRET || 'your-secret-key')

      const res = await app.request(`/api/reviews/${testReviewId}`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${otherToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          rating: 1,
          reviewText: 'Trying to update someone else\'s review'
        })
      })

      expect(res.status).toBe(403)
      const data = await res.json() as ErrorResponse
      expect(data.error).toBe('Not authorized')

      // Clean up other user
      await db.delete(users).where(eq(users.id, otherUser.id))
    })
  })

  describe('POST /api/reviews/:id/report', () => {
    it('should increment report count', async () => {
      const res = await app.request(`/api/reviews/${testReviewId}/report`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(200)
      const data = await res.json() as MessageResponse
      expect(data.message).toBe('Review reported')

      // Verify report count increased
      const [review] = await db
        .select()
        .from(reviews)
        .where(eq(reviews.id, testReviewId))
      expect(review.reportCount).toBe(1)
    })

    it('should delete review after 5 reports', async () => {
      // Report 4 more times (5 total)
      for (let i = 0; i < 4; i++) {
        await app.request(`/api/reviews/${testReviewId}/report`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${authToken}`
          }
        })
      }

      // Verify review was deleted
      const [review] = await db
        .select()
        .from(reviews)
        .where(eq(reviews.id, testReviewId))
      expect(review).toBeUndefined()
    })

    it('should handle non-existent review', async () => {
      const res = await app.request(`/api/reviews/99999/report`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(404)
      const data = await res.json() as ErrorResponse
      expect(data.error).toBe('Review not found')
    })
  })

  describe('DELETE /api/reviews/:id', () => {
    it('should delete a review', async () => {
      // Create a test review to delete
      const res = await app.request('/api/reviews', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          toiletId: testToilet.id,
          rating: 4,
          reviewText: 'Test review to delete'
        })
      })

      expect(res.status).toBe(201)
      const data = await res.json() as ReviewResponse
      const reviewId = data.review.id

      // Delete the review
      const deleteRes = await app.request(`/api/reviews/${reviewId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(deleteRes.status).toBe(200)
      const deleteData = await deleteRes.json() as MessageResponse
      expect(deleteData.message).toBe('Review deleted successfully')

      // Verify review is deleted
      const [deletedReview] = await db
        .select()
        .from(reviews)
        .where(eq(reviews.id, reviewId))
      expect(deletedReview).toBeUndefined()
    })

    it('should not allow deleting another user\'s review', async () => {
      // Create another user and their review
      const passwordHash = await bcrypt.hash('otherpassword', 10)
      const [otherUser] = await db.insert(users).values({
        username: 'otheruser' + Date.now(),
        email: 'other' + Date.now() + '@example.com',
        passwordHash
      }).returning()
      const otherToken = jwt.sign({ id: otherUser.id }, process.env.JWT_SECRET || 'your-secret-key')

      // Create a review for the other user
      const [otherReview] = await db.insert(reviews).values({
        toiletId: testToilet.id,
        userId: otherUser.id,
        rating: 4,
        reviewText: 'Other user\'s review'
      }).returning()

      // Try to delete other user's review
      const res = await app.request(`/api/reviews/${otherReview.id}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      expect(res.status).toBe(403)
      const data = await res.json() as ErrorResponse
      expect(data.error).toBe('Not authorized')

      // Clean up other user and their review
      await db.delete(reviews).where(eq(reviews.id, otherReview.id))
      await db.delete(users).where(eq(users.id, otherUser.id))
    })
  })
})
