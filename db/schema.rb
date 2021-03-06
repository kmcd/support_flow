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

ActiveRecord::Schema.define(version: 20150907153211) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "activities", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.json     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["key"], name: "index_activities_on_key", using: :btree
  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["team_id"], name: "index_activities_on_team_id", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "agents", force: :cascade do |t|
    t.integer  "team_id",             null: false
    t.string   "email_address",       null: false
    t.string   "name",                null: false
    t.integer  "invitor_id"
    t.string   "phone"
    t.text     "notes"
    t.hstore   "notification_policy"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "agents", ["team_id"], name: "index_agents_on_team_id", using: :btree

  create_table "assets", force: :cascade do |t|
    t.integer  "team_id",    null: false
    t.string   "type",       null: false
    t.string   "thumb"
    t.string   "image"
    t.string   "title"
    t.string   "link"
    t.string   "size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attachments", force: :cascade do |t|
    t.integer "team_id"
    t.integer "email_id"
    t.string  "name"
    t.string  "content_type"
    t.binary  "content"
    t.boolean "base64"
    t.integer "size"
  end

  create_table "customers", force: :cascade do |t|
    t.integer  "team_id",                    null: false
    t.string   "name",                       null: false
    t.string   "email_address"
    t.string   "phone"
    t.string   "company"
    t.text     "notes"
    t.text     "labels",        default: [],              array: true
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "customers", ["email_address"], name: "index_customers_on_email_address", using: :btree
  add_index "customers", ["team_id"], name: "index_customers_on_team_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "emails", force: :cascade do |t|
    t.string   "type"
    t.integer  "team_id"
    t.integer  "request_id"
    t.integer  "sender_id"
    t.string   "sender_type"
    t.string   "recipients"
    t.text     "message_content"
    t.json     "payload"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "guides", force: :cascade do |t|
    t.integer  "team_id",                null: false
    t.integer  "view_count", default: 0
    t.string   "name",                   null: false
    t.string   "slug"
    t.text     "content"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "guides", ["slug"], name: "index_guides_on_slug", using: :btree
  add_index "guides", ["team_id"], name: "index_guides_on_team_id", using: :btree

  create_table "logins", force: :cascade do |t|
    t.string   "email_address",                 null: false
    t.integer  "team_id"
    t.string   "token"
    t.boolean  "signup",        default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "campaign"
  end

  add_index "logins", ["email_address"], name: "index_logins_on_email", using: :btree
  add_index "logins", ["team_id"], name: "index_logins_on_team_id", using: :btree

  create_table "mailboxes", force: :cascade do |t|
    t.integer  "team_id",                    null: false
    t.string   "email_address",              null: false
    t.json     "credentials",   default: {}
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "mailboxes", ["email_address"], name: "index_mailboxes_on_email_address", using: :btree
  add_index "mailboxes", ["team_id"], name: "index_mailboxes_on_team_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "mailbox_id"
    t.integer  "request_id"
    t.integer  "customer_id"
    t.integer  "agent_id"
    t.string   "subject"
    t.text     "text_body"
    t.text     "content",     null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "messages", ["agent_id"], name: "index_mailboxes_on_agent_id", using: :btree
  add_index "messages", ["customer_id"], name: "index_mailboxes_on_customer_id", using: :btree
  add_index "messages", ["mailbox_id"], name: "index_mailboxes_on_mailbox_id", using: :btree
  add_index "messages", ["request_id"], name: "index_mailboxes_on_request_id", using: :btree

  create_table "reply_templates", force: :cascade do |t|
    t.string   "team_id",    null: false
    t.string   "name",       null: false
    t.text     "template"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "reply_templates", ["team_id"], name: "index_reply_templates_on_team_id", using: :btree

  create_table "requests", force: :cascade do |t|
    t.integer  "team_id",                     null: false
    t.integer  "number",       default: 1
    t.integer  "agent_id"
    t.integer  "customer_id"
    t.integer  "emails_count", default: 0
    t.string   "name"
    t.boolean  "open",         default: true
    t.text     "labels",       default: [],                array: true
    t.text     "notes"
    t.integer  "happiness",    default: 100
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "requests", ["agent_id"], name: "index_requests_on_agent_id", using: :btree
  add_index "requests", ["customer_id"], name: "index_requests_on_customer_id", using: :btree
  add_index "requests", ["labels"], name: "index_requests_on_labels", using: :gin
  add_index "requests", ["number"], name: "index_requests_on_number", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "statistics", force: :cascade do |t|
    t.integer  "owner_id",   null: false
    t.string   "owner_type", null: false
    t.string   "type",       null: false
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.integer  "subscription"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "teams", ["name"], name: "index_teams_on_name", using: :btree
  add_index "teams", ["subscription"], name: "index_teams_on_subscription", using: :btree

end
