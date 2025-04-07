ALTER TABLE "toilets" ALTER COLUMN "handicap_avail" DROP DEFAULT;--> statement-breakpoint
ALTER TABLE "toilets" ALTER COLUMN "bidet_avail" DROP DEFAULT;--> statement-breakpoint
ALTER TABLE "toilets" ALTER COLUMN "shower_avail" DROP DEFAULT;--> statement-breakpoint
ALTER TABLE "toilets" ALTER COLUMN "sanitiser_avail" DROP DEFAULT;--> statement-breakpoint
ALTER TABLE "toilets" ALTER COLUMN "crowd_level" SET DEFAULT 0;--> statement-breakpoint
ALTER TABLE "toilets" DROP COLUMN "toilet_avail";