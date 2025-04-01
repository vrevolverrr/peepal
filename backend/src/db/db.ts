import { Pool } from "pg";
import config from "../../drizzle.config";
import { drizzle } from "drizzle-orm/node-postgres";

// Create a new DB connection pool
export const pool = new Pool({
    ...config.dbCredentials,
    /// Switch to test database when in test environment
    database: process.env.NODE_ENV === 'test' ? 'test' : config.dbCredentials.database
  });
