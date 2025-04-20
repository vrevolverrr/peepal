import * as fs from 'fs/promises';
import { Pool } from "pg";
import { drizzle } from "drizzle-orm/node-postgres";
import config from "../drizzle.config";

async function main() {
    const pool = new Pool(config.dbCredentials);
    const db = drizzle(pool);

    const imagesSql = await fs.readFile('./scripts/sql/images.sql', 'utf8');
    await db.execute(imagesSql);

    console.log('Images seeded successfully');

    const toiletsSql = await fs.readFile('./scripts/sql/toilets.sql', 'utf8');
    await db.execute(toiletsSql);

    console.log('Toilets seeded successfully');

    const usersSql = await fs.readFile('./scripts/sql/users.sql', 'utf8');
    await db.execute(usersSql);

    console.log('Users seeded successfully');

    await pool.end();
}

main().catch((error) => {
    console.error('Error seeding database:', error);
    process.exit(1);
});