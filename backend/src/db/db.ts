import { Pool } from "pg";
import config from "../../drizzle.config";

// Create a new DB connection pool
export const pool = new Pool(config.dbCredentials);
