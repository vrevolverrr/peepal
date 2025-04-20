
# PeePal Backend

  

A modern TypeScript server application using Hono for the web framework, Drizzle ORM for database operations with PostgreSQL/PostGIS.

  

## Prerequisites

  

* [Node.js](https://nodejs.org/) (v20 or later recommended)

* [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)

* [Docker](https://www.docker.com/products/docker-desktop/)

  

## Setup Instructions

  

1.  **Clone the Repository:**

```bash
git clone https://github.com/softwarelab3/2006-FDAB-P1.git
```
  

2.  **Run Postgres (PostGIS) using Docker:**

Pull the official PostGIS image and run a container. This command maps the container's port 5432 to your host machine's port 5432, sets the default PostgreSQL user and password to `postgres`, creates a database named `peepal_db`, and names the container `peepal-postgis` for easy reference.

```bash

docker pull postgis/postgis:16-3.4

docker run --name peepal-postgis -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -e POSTGRES_DB=peepal_db -p 5432:5432 -d postgis/postgis:16-3.4

```

* *Note:* If port 5432 is already in use, change the host port (the first `5432`) to something else (e.g., `-p 5433:5432`) and update the `DB_PORT` in your `.env` file accordingly.

* To stop the container: `docker stop peepal-postgis`

* To start the container again: `docker start peepal-postgis`

* To remove the container (data will be lost unless using volumes): `docker rm peepal-postgis`

  

3.  **Navigate to Backend Directory:**

```bash
cd backend
```

  

4.  **Install Dependencies:**

```bash
npm install
# or
# yarn install
```

  

5.  **Set Up Environment Variables:**

Create a `.env` file in the `backend` directory by copying the example. Kindly email the team members for a copy of the production `.env` file to access our S3 storage bucket and production DB.
```bash
echo "" > .env
```

Review the `.env` file and adjust the variables if needed. The defaults should work with the Docker command above.

```dotenv
# Database configuration
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=peepal_db
  
# Server configuration
PORT=3000

# Add other variables like JWT_SECRET, S3 credentials etc. as needed
JWT_SECRET="your-secret-key"
# S3_ENDPOINT=
# S3_PORT=
# S3_ACCESS_KEY=
# S3_SECRET_KEY=
# S3_BUCKET=
# S3_USE_SSL=
```

*  **Important:** Replace `"your-secret-key"` with a strong, unique secret for JWT.

* Fill in the S3 bucket details for image storage.
  

6.  **Run Database Migrations:**

Apply the database schema to your running PostGIS container.

```bash

npm run migrate

# This combines generate and push steps from Drizzle Kit

```

* Alternatively, if you prefer separate steps:

```bash

npm run generate # Generate SQL migration files based on schema changes

npm run push # Apply changes directly (useful for development, less safe for prod)

```

  

7.  **Seed the Database (Optional):**

Populate the database with initial data for development/testing.

```bash

npm run seed

```

  

## Development

  

Run the development server with hot-reloading:

  

```bash

npm  run  dev

# or

# yarn dev

```

  

The server will typically be available at `http://localhost:3000` (or the port specified in your `.env` file).

  

## Other Scripts

  

*  `npm run build`: Compile TypeScript to JavaScript (output to `dist/`).

*  `npm run start`: Run the compiled JavaScript application (for production).

*  `npm run test`: Run unit/integration tests using Vitest.

*  `npm run test:watch`: Run tests in watch mode.

*  `npm run studio`: Open Drizzle Studio to browse your database.

*  `npm run generate`/`npm run push`/`npm run migrate`: Drizzle Kit database migration commands (see Step 6).

  

## Docker Build (Optional)

  

A multi-stage `Dockerfile` is included to build a production-ready container image.

  

1.  **Build the Image:**

```bash

docker build -t peepal-backend .

```

  

2.  **Run the Container:**

Remember to provide the necessary environment variables (e.g., through a mounted `.env` file or Docker's `-e` flags).

```bash
docker run -p 3000:3000 --env-file ./.env --name peepal-backend-app -d peepal-backend
```

* This assumes your database is accessible from the container (e.g., another container on the same Docker network, or a cloud database).

* The Dockerfile exposes port 3000.