import { sql } from 'drizzle-orm';
import { images } from './images'
import { pgTable, index, text, boolean, integer, decimal, geometry } from 'drizzle-orm/pg-core'

/**
 * Schema for `toilets` table. This table stores our application data on toilets.
 */
export const toilets = pgTable('toilets', {
  // The ID of the toilet.
  id: text('id').primaryKey(),

  // The name of the toilet.
  name: text('name').notNull(),

  // The address of the toilet.
  address: text('address').notNull(),

  // The location of the toilet.
  location: geometry('location', { type: 'point', mode: 'xy', srid: 4326 }).notNull(),

  // Whether the toilet is handicap accessible.
  handicapAvail: boolean('handicap_avail'),

  // Whether the toilet has a bidet.
  bidetAvail: boolean('bidet_avail'),

  // Whether the toilet has a shower.
  showerAvail: boolean('shower_avail'),

  // Whether the toilet has a sanitiser.
  sanitiserAvail: boolean('sanitiser_avail'),

  // The current crowd level of the toilet.
  crowdLevel: integer('crowd_level').notNull().default(0),

  // The rating of the toilet.
  rating: decimal('rating', { precision: 3, scale: 2 }).default('0.00'),

  // The token that is used to identify this image resource entry.
  imageToken: text('image_token').references(() => images.token, { onDelete: 'set null' }),

  // The number of times this toilet has been reported for non-existence.
  reportCount: integer('report_count').default(0)
}, (t) => [
  index('idx_toilets_id').on(t.id),
  /// Spatial index for PostGIS
  index('idx_toilets_spatial_location').using('gist', t.location),
  /// Full-text search index for address
  index('idx_toilets_address_search').using('gin', sql`to_tsvector('english', ${t.address})`)
]);
