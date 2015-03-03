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

ActiveRecord::Schema.define(version: 20150302193411) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "agents", force: :cascade do |t|
    t.integer  "team_id",                       null: false
    t.string   "email_address",                 null: false
    t.boolean  "active",        default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end
  
  add_index "agents", ["team_id"], name: "index_agents_on_team_id", using: :btree

  create_table "customers", force: :cascade do |t|
    t.string   "name"
    t.string   "email_address",      null: false
    t.hstore   "profile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.integer  "team_id",    null: false
    t.string   "type",       null: false
    t.json     "payload",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
  
  add_index "events", ["type"], name: "index_events_on_type", using: :btree

  create_table "guides", force: :cascade do |t|
    t.integer  "team_id",    null: false
    t.string   "name",       null: false
    t.text     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mailboxes", force: :cascade do |t|
    t.integer  "team_id",       null: false
    t.string   "email_address", null: false
    t.string   "credentials",   null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end
  
  add_index "mailboxes", ["team_id"], name: "index_mailboxes_on_team_id", using: :btree
  add_index "mailboxes", ["email_address"], name: "index_mailboxes_on_email_address", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "mailbox_id", null: false
    t.text     "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
  
  add_index "messages", ["mailbox_id"], name: "index_mailboxes_on_mailbox_id", using: :btree

  create_table "requests", force: :cascade do |t|
    t.integer  "mailbox_id",                 null: false
    t.integer  "agent_id"
    t.integer  "customer_id",                null: false
    t.boolean  "open",        default: true, null: false
    t.text     "tags",        default: [],                array: true
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end
  
  add_index "requests", ["mailbox_id"], name: "index_requests_on_mailbox_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "subdomain"
    t.string   "domain_name"
    t.hstore   "billing_info"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end
end
