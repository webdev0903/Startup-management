# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150712151650) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "cofounders", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "startup_id"
  end

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.integer  "startup_id"
    t.text     "text"
    t.integer  "likes_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversations", force: true do |t|
    t.integer  "user_id"
    t.integer  "recipient_id"
    t.datetime "last_action_at"
    t.boolean  "new"
    t.integer  "private_message_id"
    t.boolean  "user_hide"
    t.boolean  "recipient_hide"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url_slug"
  end

  create_table "cronjobs", force: true do |t|
    t.string   "title"
    t.integer  "interval"
    t.datetime "last_at"
    t.datetime "next_at"
    t.boolean  "status"
    t.string   "url"
    t.integer  "quantity"
    t.integer  "started"
    t.integer  "ended"
    t.integer  "ms"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "errors_count"
    t.string   "answer"
  end

  create_table "email_settings", force: true do |t|
    t.integer  "user_id"
    t.boolean  "private_messages",        default: true
    t.boolean  "morning_mail",            default: true
    t.datetime "last_email_at"
    t.datetime "next_email_at"
    t.integer  "emails_count"
    t.integer  "admin_emails"
    t.integer  "confirmed_emails"
    t.integer  "welcome_emails"
    t.string   "hash_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "google"
    t.boolean  "subscription",            default: true
    t.boolean  "discuss_trending",        default: true
    t.boolean  "startup_update_reminder", default: true
  end

  create_table "followers", force: true do |t|
    t.integer  "user_id"
    t.integer  "recipient_id"
    t.integer  "startup_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", force: true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.boolean  "status"
    t.boolean  "new"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "lagacy_photo"
    t.string   "url"
    t.string   "about"
    t.text     "long_about"
    t.integer  "privacy"
    t.boolean  "status"
    t.boolean  "homepage"
    t.boolean  "trending"
    t.datetime "last_action_at"
    t.integer  "members_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "item_comments", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "item_id",    null: false
    t.text     "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: true do |t|
    t.string   "title",                           null: false
    t.string   "url"
    t.text     "content"
    t.integer  "user_id",                         null: false
    t.boolean  "disabled",        default: false, null: false
    t.integer  "comments_count",  default: 0,     null: false
    t.integer  "upvotes_count",   default: 0,     null: false
    t.integer  "downvotes_count", default: 0,     null: false
    t.integer  "score",           default: 0,     null: false
    t.integer  "rank",            default: 0,     null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "uri"
  end

  add_index "items", ["disabled"], name: "index_items_on_disabled", using: :btree
  add_index "items", ["user_id"], name: "index_items_on_user_id", using: :btree

  create_table "keywords", force: true do |t|
    t.integer  "parent_id"
    t.string   "title"
    t.string   "url"
    t.boolean  "skill"
    t.boolean  "market"
    t.integer  "users_count"
    t.integer  "startups_count"
    t.integer  "followers_count"
    t.boolean  "status"
    t.datetime "synced_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "likes", force: true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.integer  "recipient_id"
    t.integer  "comment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", force: true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.boolean  "status"
    t.boolean  "suggested"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "moves", force: true do |t|
    t.integer  "user_id"
    t.integer  "conversations"
    t.integer  "photos"
    t.integer  "statistics"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: true do |t|
    t.integer  "user_id"
    t.integer  "recipient_id"
    t.string   "key_name"
    t.integer  "post_id"
    t.integer  "comment_id"
    t.integer  "like_id"
    t.integer  "startup_id"
    t.integer  "friendship_id"
    t.integer  "follower_id"
    t.boolean  "read"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cofounder_id"
    t.integer  "group_id"
  end

  create_table "posts", force: true do |t|
    t.integer  "user_id"
    t.integer  "startup_id"
    t.text     "text"
    t.boolean  "for_friends"
    t.boolean  "for_followers"
    t.boolean  "for_public"
    t.integer  "likes_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "for_cofounders"
    t.integer  "group_id"
  end

  add_index "posts", ["group_id"], name: "index_posts_on_group_id", using: :btree

  create_table "private_messages", force: true do |t|
    t.integer  "user_id"
    t.integer  "recipient_id"
    t.integer  "conversation_id"
    t.text     "text"
    t.boolean  "new"
    t.boolean  "user_deleted"
    t.boolean  "recipient_deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "startup_statistics", force: true do |t|
    t.integer  "startup_id"
    t.integer  "followers_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "startups", force: true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "summary"
    t.integer  "country_id"
    t.string   "city"
    t.string   "url"
    t.text     "about"
    t.string   "require"
    t.string   "website"
    t.string   "angellist"
    t.string   "twitter"
    t.string   "facebook"
    t.boolean  "status"
    t.boolean  "english"
    t.boolean  "homepage"
    t.boolean  "trending"
    t.integer  "followers_count"
    t.datetime "last_action_at"
    t.string   "filename"
    t.integer  "cofounders_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "markets",            default: [], null: false, array: true
    t.string   "lagacy_photo"
    t.datetime "last_email_at"
  end

  add_index "startups", ["url"], name: "index_startups_on_url", using: :btree
  add_index "startups", ["user_id"], name: "index_startups_on_user_id", using: :btree

  create_table "twitter_tweets", force: true do |t|
    t.integer  "group_id"
    t.integer  "recipient_user_id"
    t.integer  "startup_id"
    t.string   "text"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "twitter_tweets", ["group_id"], name: "index_twitter_tweets_on_group_id", using: :btree
  add_index "twitter_tweets", ["recipient_user_id"], name: "index_twitter_tweets_on_recipient_user_id", using: :btree
  add_index "twitter_tweets", ["startup_id"], name: "index_twitter_tweets_on_startup_id", using: :btree
  add_index "twitter_tweets", ["user_id"], name: "index_twitter_tweets_on_user_id", using: :btree

  create_table "user_facebooks", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.decimal  "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_parameters", force: true do |t|
    t.integer  "user_id"
    t.integer  "country_id"
    t.integer  "user_role_id"
    t.string   "city"
    t.string   "summary"
    t.text     "experience"
    t.string   "current_position"
    t.string   "looking_for"
    t.text     "startup_join_conditions"
    t.text     "startup_conditions"
    t.text     "startup_add_value"
    t.string   "startup_locations"
    t.string   "website",                 default: [],              array: true
    t.string   "angellist"
    t.string   "twitter"
    t.string   "linkedin"
    t.datetime "last_email_at"
    t.datetime "next_email_at"
    t.integer  "emails_count"
    t.integer  "referal_id"
    t.string   "referal_code"
    t.boolean  "fix"
    t.integer  "step"
    t.boolean  "ask_me"
    t.boolean  "startup_join"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "skills",                  default: [], null: false, array: true
    t.string   "markets_interested_in",   default: [], null: false, array: true
  end

  add_index "user_parameters", ["country_id"], name: "index_user_parameters_on_country_id", using: :btree
  add_index "user_parameters", ["markets_interested_in"], name: "index_user_parameters_on_markets_interested_in", using: :gin
  add_index "user_parameters", ["skills"], name: "index_user_parameters_on_skills", using: :gin
  add_index "user_parameters", ["user_id"], name: "index_user_parameters_on_user_id", using: :btree
  add_index "user_parameters", ["user_role_id"], name: "index_user_parameters_on_user_role_id", using: :btree

  create_table "user_roles", force: true do |t|
    t.string   "title"
    t.string   "url"
    t.integer  "users_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_statistics", force: true do |t|
    t.integer  "user_id"
    t.integer  "comments_count"
    t.integer  "posts_count"
    t.integer  "conversations_count"
    t.boolean  "fix"
    t.integer  "likes_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "friends_count"
    t.integer  "followers_count"
    t.integer  "followings_count"
  end

  create_table "user_twitters", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "tweets_count"
    t.integer  "tweets_per_day"
    t.datetime "next_send_at"
    t.decimal  "uid"
    t.boolean  "revoked"
    t.string   "secret"
    t.string   "oauth_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "title"
    t.string   "url"
    t.string   "old_password"
    t.datetime "last_action_at"
    t.boolean  "status"
    t.boolean  "admin",                  default: false
    t.string   "filename"
    t.string   "timezone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean  "homepage"
    t.string   "lagacy_photo"
    t.string   "twitter_id"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "remember_token"
    t.boolean  "activable",              default: false
    t.boolean  "tweet_opt_in",           default: true
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["url"], name: "index_users_on_url", using: :btree

  create_table "votes", force: true do |t|
    t.integer  "user_id",      null: false
    t.integer  "votable_id",   null: false
    t.string   "votable_type", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "votes", ["user_id", "votable_id", "votable_type"], name: "index_votes_on_user_id_and_votable_id_and_votable_type", unique: true, using: :btree

end
