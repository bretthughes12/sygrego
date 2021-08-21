# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_08_21_003104) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audit_trails", force: :cascade do |t|
    t.integer "record_id"
    t.string "record_type", limit: 30
    t.string "event", limit: 20
    t.integer "user_id"
    t.datetime "created_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "sports", force: :cascade do |t|
    t.string "name", limit: 20, null: false
    t.string "classification", limit: 10, null: false
    t.boolean "active", default: true
    t.integer "max_indiv_entries_group", default: 0, null: false
    t.integer "max_team_entries_group", default: 0, null: false
    t.integer "max_entries_indiv", default: 0, null: false
    t.string "draw_type", limit: 20, null: false
    t.boolean "bonus_for_officials", default: false
    t.string "court_name", limit: 20, default: "Court"
    t.integer "lock_version", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
