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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130611192627) do

  create_table "callers", :force => true do |t|
    t.string   "number"
    t.datetime "last_call_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "calls", :force => true do |t|
    t.string   "rec_url"
    t.string   "twillio_sid"
    t.string   "status"
    t.integer  "rec_length"
    t.integer  "play_count"
    t.integer  "play_length"
    t.integer  "caller_id"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "events", :force => true do |t|
    t.integer  "caller_id"
    t.integer  "call_id"
    t.string   "globals"
    t.string   "verb"
    t.string   "params"
    t.datetime "time"
    t.integer  "feed_level",      :default => 30
    t.integer  "storage_level",   :default => 30
    t.integer  "log_level",       :default => 10
    t.integer  "broadcast_level", :default => 30
    t.integer  "lifetime",        :default => 86400
    t.datetime "expires_at"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

end
