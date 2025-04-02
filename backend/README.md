# TypeScript Server with Hono and Drizzle ORM

A modern TypeScript server application using Hono for the web framework and Drizzle ORM for database operations.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Set up your environment variables (optional):
```bash
# Database configuration
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=postgres

# Server configuration
PORT=3000
```

3. Generate database migrations:
```bash
npm run generate
```

4. Push migrations to the database:
```bash
npm run push
```

## Development

Run the development server:
```bash
npm run dev
```

## Build and Production

Build the project:
```bash
npm run build
```

Run in production:
```bash
npm start
```

## Project Structure

- `src/main.ts` - Main application entry point
- `src/db/schema.ts` - Database schema definitions
- `drizzle.config.ts` - Drizzle ORM configuration
- `drizzle/` - Generated migrations
