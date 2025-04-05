import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { Hono } from 'hono';
import { toiletApi } from '../routes/api/toilet';

interface ToiletResponse {
  toilet: {
    id: number;
    name: string;
    address: string;
    location: string;
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
  let app: Hono;

  beforeAll(() => {
    app = new Hono();
    app.route('/api/toilets', toiletApi);
  });

  const mockToilet = {
    name: 'Test Toilet',
    address: '123 Test Street',
    location: 'Test Location',
    toiletAvail: true,
    handicapAvail: true,
    bidetAvail: false,
    showerAvail: false,
    sanitiserAvail: true,
    crowdLevel: 'LOW',
    rating: 4.5,
    imageUrl: 'http://example.com/image.jpg',
    reportCount: 0
  };

  describe('POST /api/toilets/create', () => {
    it('should create a new toilet with valid data', async () => {
      const res = await app.request('/api/toilets/create', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(mockToilet),
      });

      expect(res.status).toBe(200);
      const data = await res.json() as ToiletResponse;
      expect(data.toilet).toBeDefined();
      expect(data.toilet.name).toBe(mockToilet.name);
    });

    it('should return 400 when required fields are missing', async () => {
      const invalidToilet = {
        name: 'Test Toilet',
        // missing required fields
      };

      const res = await app.request('/api/toilets/create', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(invalidToilet),
      });

      expect(res.status).toBe(400);
    });
  });

  describe('PUT /api/toilets/{id}', () => {
    it('should update an existing toilet', async () => {
      const updateData = {
        name: 'Updated Toilet Name',
        crowdLevel: 'HIGH',
      };

      const res = await app.request('/api/toilets/1', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(updateData),
      });

      expect(res.status).toBe(200);
      const data = await res.json() as ToiletResponse;
      expect(data.toilet).toBeDefined();
      expect(data.toilet.name).toBe(updateData.name);
    });

    it('should return 404 for non-existent toilet', async () => {
      const res = await app.request('/api/toilets/999', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ name: 'Test' }),
      });

      expect(res.status).toBe(404);
    });
  });

  describe('DELETE /api/toilets/{id}', () => {
    it('should delete an existing toilet', async () => {
      const res = await app.request('/api/toilets/1', {
        method: 'DELETE',
      });

      expect(res.status).toBe(200);
      const data = await res.json() as ToiletResponse;
      expect(data.toilet).toBeDefined();
    });

    it('should return 400 for non-existent toilet', async () => {
      const res = await app.request('/api/toilets/999', {
        method: 'DELETE',
      });

      expect(res.status).toBe(400);
    });
  });
});
