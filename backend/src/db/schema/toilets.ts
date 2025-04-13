import { sql } from 'drizzle-orm';
import { images } from './images'
import { pgTable, index, text, boolean, integer, decimal, geometry } from 'drizzle-orm/pg-core'

export const toilets = pgTable('toilets', {
  id: text('id').primaryKey(),
  name: text('name').notNull(),
  address: text('address').notNull(),
  location: geometry('location', { type: 'point', mode: 'xy', srid: 4326 }).notNull(),
  handicapAvail: boolean('handicap_avail'),
  bidetAvail: boolean('bidet_avail'),
  showerAvail: boolean('shower_avail'),
  sanitiserAvail: boolean('sanitiser_avail'),
  crowdLevel: integer('crowd_level').notNull().default(0),
  rating: decimal('rating', { precision: 3, scale: 2 }).default('0.00'),
  imageToken: text('image_token').references(() => images.token, { onDelete: 'set null' }),
  reportCount: integer('report_count').default(0)
},  (t) => [
  index('idx_toilets_id').on(t.id),
  index('idx_toilets_spatial_location').using('gist', t.location),
  index('idx_toilets_address_search').using('gin', sql`to_tsvector('english', ${t.address})`)
]);
