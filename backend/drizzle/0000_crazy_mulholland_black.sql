CREATE TYPE "public"."gender" AS ENUM('male', 'female', 'others');--> statement-breakpoint
CREATE TABLE "users" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"username" text NOT NULL,
	"email" text NOT NULL,
	"password_hash" text NOT NULL,
	"gender" "gender",
	"created_at" timestamp DEFAULT now(),
	CONSTRAINT "users_username_unique" UNIQUE("username"),
	CONSTRAINT "users_email_unique" UNIQUE("email")
);
--> statement-breakpoint
CREATE TABLE "toilets" (
	"id" text PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"address" text NOT NULL,
	"location" geometry(point) NOT NULL,
	"handicap_avail" boolean,
	"bidet_avail" boolean,
	"shower_avail" boolean,
	"sanitiser_avail" boolean,
	"crowd_level" integer DEFAULT 0 NOT NULL,
	"rating" numeric(3, 2) DEFAULT '0.00',
	"image_token" text,
	"report_count" integer DEFAULT 0
);
--> statement-breakpoint
CREATE TABLE "reviews" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" uuid NOT NULL,
	"toilet_id" text NOT NULL,
	"rating" integer NOT NULL,
	"review_text" text,
	"created_at" timestamp DEFAULT now(),
	"image_token" text,
	"report_count" integer DEFAULT 0
);
--> statement-breakpoint
CREATE TABLE "favorites" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" uuid NOT NULL,
	"toilet_id" text NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "history" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" uuid,
	"toilet_id" text,
	"visited_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "images" (
	"token" text PRIMARY KEY NOT NULL,
	"type" text NOT NULL,
	"user_id" uuid,
	"filename" text NOT NULL,
	"uploaded_at" timestamp DEFAULT now()
);
--> statement-breakpoint
ALTER TABLE "toilets" ADD CONSTRAINT "toilets_image_token_images_token_fk" FOREIGN KEY ("image_token") REFERENCES "public"."images"("token") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_toilet_id_toilets_id_fk" FOREIGN KEY ("toilet_id") REFERENCES "public"."toilets"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "favorites" ADD CONSTRAINT "favorites_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "favorites" ADD CONSTRAINT "favorites_toilet_id_toilets_id_fk" FOREIGN KEY ("toilet_id") REFERENCES "public"."toilets"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "history" ADD CONSTRAINT "history_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "history" ADD CONSTRAINT "history_toilet_id_toilets_id_fk" FOREIGN KEY ("toilet_id") REFERENCES "public"."toilets"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "images" ADD CONSTRAINT "images_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_users_id" ON "users" USING btree ("id");--> statement-breakpoint
CREATE INDEX "idx_users_username" ON "users" USING btree ("username");--> statement-breakpoint
CREATE INDEX "idx_users_email" ON "users" USING btree ("email");--> statement-breakpoint
CREATE INDEX "idx_toilets_id" ON "toilets" USING btree ("id");--> statement-breakpoint
CREATE INDEX "idx_toilets_spatial_location" ON "toilets" USING gist ("location");--> statement-breakpoint
CREATE INDEX "idx_toilets_address_search" ON "toilets" USING gin (to_tsvector('english', "address"));--> statement-breakpoint
CREATE INDEX "idx_favorites_id" ON "favorites" USING btree ("id");--> statement-breakpoint
CREATE INDEX "idx_favorites_user_id" ON "favorites" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "idx_favorites_toilet_id" ON "favorites" USING btree ("toilet_id");