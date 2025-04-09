CREATE TABLE "images" (
	"token" text PRIMARY KEY NOT NULL,
	"type" text NOT NULL,
	"user_id" uuid NOT NULL,
	"filename" text NOT NULL,
	"uploaded_at" timestamp DEFAULT now()
);
--> statement-breakpoint
ALTER TABLE "images" ADD CONSTRAINT "images_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;