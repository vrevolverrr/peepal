DROP INDEX "idx_spatial_toilets_location";--> statement-breakpoint
CREATE INDEX "idx_users_id" ON "users" USING btree ("id");--> statement-breakpoint
CREATE INDEX "idx_users_username" ON "users" USING btree ("username");--> statement-breakpoint
CREATE INDEX "idx_users_email" ON "users" USING btree ("email");--> statement-breakpoint
CREATE INDEX "idx_toilets_id" ON "toilets" USING btree ("id");--> statement-breakpoint
CREATE INDEX "idx_toilets_spatial_location" ON "toilets" USING gist ("location");--> statement-breakpoint
CREATE INDEX "idx_favorites_id" ON "favorites" USING btree ("id");--> statement-breakpoint
CREATE INDEX "idx_favorites_user_id" ON "favorites" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "idx_favorites_toilet_id" ON "favorites" USING btree ("toilet_id");