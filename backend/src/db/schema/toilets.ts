import { pgTable, index, serial, text, boolean, integer, decimal, geometry } from 'drizzle-orm/pg-core'

export const toilets = pgTable('toilets', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  address: text('address').notNull(),
  location: geometry('location', { type: 'point', mode: 'xy', srid: 4326 }).notNull(),
  handicapAvail: boolean('handicap_avail'),
  bidetAvail: boolean('bidet_avail'),
  showerAvail: boolean('shower_avail'),
  sanitiserAvail: boolean('sanitiser_avail'),
  crowdLevel: integer('crowd_level').notNull().default(0),
  rating: decimal('rating', { precision: 3, scale: 2 }).default('0.00'),
  imageUrl: text('image_url'),
  reportCount: integer('report_count').default(0)
},  (t) => [
  index('idx_spatial_toilets_location').using('gist', t.location),
]);
