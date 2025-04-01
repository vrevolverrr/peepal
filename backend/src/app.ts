import { Hono } from "hono";
import { drizzle } from "drizzle-orm/node-postgres";
import { cors } from "hono/cors";
import auth from './routes/auth';
import { authMiddleware } from './middleware/auth';
import { logger } from './middleware/logger';
import { pool } from "./db/db";

export const db = drizzle(pool);
export const app = new Hono();

// Use CORS middleware
app.use("/*", cors());

// Use logger middleware
app.use("/*", logger);


// Public routes
app.get("/", (c) => {
  return c.json({ message: "Hello from Hono!" });
});

// Auth routes
app.route('/auth', auth);

// API routes are routed through the `authMiddleware` to ensure
// that only authenticated users with valid `JWT` can access
app.use('/api/*', authMiddleware);
