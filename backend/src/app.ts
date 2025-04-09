import { Hono } from "hono";
import { drizzle } from "drizzle-orm/node-postgres";
import { cors } from "hono/cors";
import * as Minio from 'minio';
import { logger } from './middleware/logger';
import { pool } from "./db/db";
import { authMiddleware } from './middleware/auth';
import auth from './routes/auth';
import toiletApi from "./routes/api/toilets";
import userApi from "./routes/api/user";
import reviewApi from "./routes/api/reviews";
import favoritesApi from "./routes/api/favorites";
import imageApi from "./routes/api/images";

// Create a `db` instance with the default connection pool
export const db = drizzle(pool);

// Create a minio instance to connect to S3 bucket
export const minio = new Minio.Client({
  endPoint: process.env.S3_ENDPOINT || '',
  port: 443,
  pathStyle: true,
  useSSL: true,
  region: process.env.S3_REGION || '',
  accessKey: process.env.S3_ACCESS_KEY || '',
  secretKey: process.env.S3_SECRET_KEY || '',
})

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
});

/// API Routes
app.route('/api/user', userApi);
app.route('/api/toilets', toiletApi);
app.route('/api/reviews', reviewApi);
app.route('/api/favorites', favoritesApi);
app.route('/api/images', imageApi);

/// Global handlers
app.onError((err, c) => {
  console.error(err)
  return c.json({ error: err.message }, 500)
})

app.notFound((c) => {
  return c.json({ error: 'Not Found' }, 404)
})

export default app
