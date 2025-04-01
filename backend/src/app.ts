import { serve } from "@hono/node-server";
import { Hono } from "hono";
import { drizzle } from "drizzle-orm/node-postgres";
import { cors } from "hono/cors";
import auth from './routes/auth';
import { authMiddleware } from './middleware/auth';
import { pool } from "./db/db";

export const db = drizzle(pool);
export const app = new Hono();

// Use CORS middleware
app.use("/*", cors());

// Public routes
app.get("/", (c) => {
  return c.json({ message: "Hello from Hono!" });
});

// Auth routes
app.route('/auth', auth);

// Protected routes example
app.use('/api/*', authMiddleware);
app.get('/api/protected', (c) => {
  const user = c.get('user');
  return c.json({ message: 'Protected route', user });
});

