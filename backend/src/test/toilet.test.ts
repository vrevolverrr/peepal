import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
import { app, db } from '../app';
import { users, toilets } from '../db/schema';
import { eq } from 'drizzle-orm';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';

interface ToiletResponse {
  toilet: {
    id: number;
    name: string;
    address: string;
    location: {
      x: number;
      y: number;
    };
    toiletAvail: boolean;
    handicapAvail?: boolean;
    bidetAvail?: boolean;
    showerAvail?: boolean;
    sanitiserAvail?: boolean;
    crowdLevel?: string;
    rating?: number;
    imageUrl?: string;
    reportCount?: number;
  };
}

describe('Toilet API Tests', () => {
  let testUser: any;
  let authToken: string;
  let createdToiletId: number;

  beforeAll(async () => {
    // Clean up any existing test user
    await db.delete(users).where(eq(users.email, 'toilet@example.com'));

    // Create test user directly in DB
    const passwordHash = await bcrypt.hash('testpassword', 10);
    const [user] = await db.insert(users).values({
      username: 'toiletuser',
      email: 'toilet@example.com',
      passwordHash,
      gender: 'male'
    }).returning();

    testUser = user;
    authToken = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'your-secret-key');
  });

  /*afterAll(async () => {
    // Clean up test data
    await db.delete(toilets);
    await db.delete(users).where(eq(users.email, 'toilet@example.com'));
  });*/

  /*beforeEach(async () => {
    // Clean up toilets before each test
    await db.delete(toilets);
  });*/

  const mockToilet = {
    name: 'Test Toilet',
    address: '123 Test Street',
    location: {
      x: 51.5074,  // Longitude (example: London)
      y: 0.1278,   // Latitude (example: London)
    },
    toiletAvail: true,
    handicapAvail: true,
    bidetAvail: false,
    showerAvail: false,
    sanitiserAvail: true,
    crowdLevel: 1,
    rating: 4.5,
    imageUrl: 'http://example.com/image.jpg',
    reportCount: 0
  };

  describe('POST /api/toilet/create', () => {
    it('should create a new toilet with valid data', async () => {
      const res = await app.request('/api/toilet/create', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${authToken}`
        },
        body: JSON.stringify(mockToilet),
      });

      expect(res.status).toBe(200);
      const data = await res.json() as ToiletResponse;
      expect(data.toilet).toBeDefined();
      expect(data.toilet.name).toBe(mockToilet.name);
      console.log('Created toilet:', data.toilet);
      createdToiletId = data.toilet.id;
      console.log('Stored toilet ID:', createdToiletId, 'typeof:', typeof createdToiletId);
    });

    it('should return 400 when required fields are missing', async () => {
      const invalidToilet = {
        name: 'Test Toilet',
        // missing required fields
      };

      const res = await app.request('/api/toilet/create', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${authToken}`
        },
        body: JSON.stringify(invalidToilet),
      });

      expect(res.status).toBe(400);
    });
  });


  describe('PUT /api/toilet/{id}', () => {
    it('should update an existing toilet', async () => {
      console.log('Attempting to update toilet with ID:', createdToiletId, 'typeof:', typeof createdToiletId);
      
      // Verify toilet exists in database
      const [dbToilet] = await db
        .select()
        .from(toilets)
        .where(eq(toilets.id, createdToiletId));
      
      console.log('Found toilet in database:', dbToilet);

      const updateData = {
        name: 'Updated Toilet Name',
        crowdLevel: 2,
      };

      const res = await app.request(`/api/toilet/${createdToiletId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${authToken}`
        },
        body: JSON.stringify(updateData),
      });

      console.log('Update response status:', res.status);
      const responseText = await res.text();
      console.log('Update response body:', responseText);

      expect(res.status).toBe(200);
      const data = await JSON.parse(responseText) as ToiletResponse;
      expect(data.toilet).toBeDefined();
      expect(data.toilet.name).toBe(updateData.name);
    });

    it('should return 404 for non-existent toilet', async () => {
      const res = await app.request('/api/toilet/999', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${authToken}`
        },
        body: JSON.stringify({ name: 'Test' }),
      });

      expect(res.status).toBe(404);
    });
  });

  
  describe('DELETE /api/toilet/{id}', () => {
    let createdToiletId: number;

    beforeEach(async () => {
      // Create a test toilet first
      const createRes = await app.request('/api/toilet/create', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${authToken}`
        },
        body: JSON.stringify(mockToilet)
      });

      const data = await createRes.json() as ToiletResponse;
      createdToiletId = data.toilet.id;
    });

    it('should delete an existing toilet', async () => {
      const res = await app.request(`/api/toilet/${createdToiletId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      });

      expect(res.status).toBe(200);
      const data = await res.json() as ToiletResponse;
      expect(data.toilet).toBeDefined();
    });

    it('should return 404 for non-existent toilet', async () => {
      const res = await app.request('/api/toilet/999', {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      });

      expect(res.status).toBe(404);
    });
  }); 
});