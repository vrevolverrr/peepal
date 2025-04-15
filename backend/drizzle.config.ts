import { Config } from 'drizzle-kit'
 
export default {
  schema: './src/db/schema.ts',
  out: './drizzle',
  dialect: 'postgresql',
  extensionsFilters: ['postgis'],
  dbCredentials: {
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT) || 5432,
    user: process.env.DB_USER || 'sc2006',
    password: process.env.DB_PASSWORD || 'sc2006',
    database: process.env.DB_NAME || 'sc2006',
    ssl: false
  },
  tablesFilter: ['!us_gaz', '!us_rules', '!us_lex']
} satisfies Config