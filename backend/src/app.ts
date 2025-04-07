import { Hono } from "hono";
import { drizzle } from "drizzle-orm/node-postgres";
import { cors } from "hono/cors";
import { logger } from './middleware/logger';
import { pool } from "./db/db";
import { authMiddleware } from './middleware/auth';
import auth from './routes/auth';
import toiletApi from "./routes/api/toilet";
import userApi from "./routes/api/user";
import reviewApi from "./routes/api/reviews";
import favoritesApi from "./routes/api/favorites";

// Create a `db` instance with the default connection pool
export const db = drizzle(pool);

// The root `Hono` application
export const app = new Hono();

// Use CORS middleware
app.use("/*", cors());

// Use logger middleware
app.use("/*", logger);

// Auth routes
app.route('/auth', auth);

// API routes are routed through the `authMiddleware` to ensure
// that only authenticated users with valid `JWT` can access
app.use('/api/*', authMiddleware);

app.get('/api', async (c) => {
    return c.json({ message: 'Protected route', user: c.get('user') }, 200)
})
/// API Routes
app.route('/api/users', userApi);
app.route('/api/toilet', toiletApi);
app.route('/api/reviews', reviewApi);
app.route('/api/favorites', favoritesApi);

/// Global handlers
app.onError((err, c) => {
  console.error(err)
  return c.json({ error: err.message }, 500)
})

app.notFound((c) => {
  return c.json({ error: 'Not Found' }, 404)
})

export default app
