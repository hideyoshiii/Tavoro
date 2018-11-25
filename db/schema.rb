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

ActiveRecord::Schema.define(version: 20181125003835) do

  create_table "follow_requests", force: :cascade do |t|
    t.integer "requester_id"
    t.integer "requesting_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["requester_id", "requesting_id"], name: "index_follow_requests_on_requester_id_and_requesting_id", unique: true
    t.index ["requester_id"], name: "index_follow_requests_on_requester_id"
    t.index ["requesting_id"], name: "index_follow_requests_on_requesting_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "invited_user_id"
    t.string "code"
    t.boolean "used", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_invitations_on_code", unique: true
    t.index ["invited_user_id"], name: "index_invitations_on_invited_user_id"
    t.index ["user_id"], name: "index_invitations_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lists", force: :cascade do |t|
    t.integer "user_id"
    t.integer "post_id"
    t.string "title"
    t.text "description"
    t.boolean "private", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_lists_on_post_id"
    t.index ["user_id"], name: "index_lists_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id"
    t.integer "notified_by_id"
    t.string "notified_type"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notified_by_id"], name: "index_notifications_on_notified_by_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.decimal "work_id", precision: 50, scale: 10
    t.string "category"
    t.string "review"
    t.text "description"
    t.string "image_url"
    t.string "preview_url"
    t.string "favorite"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "relationships", force: :cascade do |t|
    t.integer "follower_id"
    t.integer "following_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["follower_id", "following_id"], name: "index_relationships_on_follower_id_and_following_id", unique: true
    t.index ["follower_id"], name: "index_relationships_on_follower_id"
    t.index ["following_id"], name: "index_relationships_on_following_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.text "description"
    t.string "username"
    t.string "authority"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
