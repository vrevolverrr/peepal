import { pgTable, serial, text, boolean, integer, decimal } from 'drizzle-orm/pg-core'

export const toilets = pgTable('toilets', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  address: text('address').notNull(),
  location: text('location').notNull(),
  toiletAvail: boolean('toilet_avail').default(false),
  handicapAvail: boolean('handicap_avail').default(false),
  bidetAvail: boolean('bidet_avail').default(false),
  showerAvail: boolean('shower_avail').default(false),
  sanitiserAvail: boolean('sanitiser_avail').default(false),
  crowdLevel: integer('crowd_level').notNull(),
  rating: decimal('rating', { precision: 3, scale: 2 }).default('0.00'),
  imageUrl: text('image_url'),
  reportCount: integer('report_count').default(0)
});
