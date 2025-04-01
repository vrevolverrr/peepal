"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.db = void 0;
const node_server_1 = require("@hono/node-server");
const hono_1 = require("hono");
const node_postgres_1 = require("drizzle-orm/node-postgres");
const pg_1 = require("pg");
const cors_1 = require("hono/cors");
const app = new hono_1.Hono();
app.use("/*", (0, cors_1.cors)());
// Database connection
const pool = new pg_1.Pool({
    host: process.env.DB_HOST || "localhost",
    port: Number(process.env.DB_PORT) || 5432,
    user: process.env.DB_USER || "postgres",
    password: process.env.DB_PASSWORD || "sc2006",
    database: process.env.DB_NAME || "postgres",
});
exports.db = (0, node_postgres_1.drizzle)(pool);
// Routes
app.get("/", (c) => {
    return c.json({ message: "Hello from Hono!" });
});
// Start the server
const port = Number(process.env.PORT) || 3000;
console.log(`Server is running on port ${port}`);
(0, node_server_1.serve)({
    fetch: app.fetch,
    port,
});
