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

ActiveRecord::Schema[8.1].define(version: 2025_12_30_041329) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_trails", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "event", limit: 20
    t.bigint "record_id"
    t.string "record_type", limit: 30
    t.bigint "user_id"
  end

  create_table "awards", force: :cascade do |t|
    t.string "category", limit: 20, null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.boolean "flagged", default: false
    t.string "name", limit: 100, null: false
    t.string "submitted_by", limit: 100, null: false
    t.string "submitted_group", limit: 100, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_awards_on_name"
  end

  create_table "ballot_results", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "entry_limit"
    t.integer "factor"
    t.string "grade_name", limit: 50, null: false
    t.string "group_name", limit: 50, null: false
    t.boolean "new_group"
    t.boolean "one_entry_per_group"
    t.boolean "over_limit"
    t.string "preferred_section_name", limit: 50
    t.string "section_name", limit: 50
    t.string "sport_entry_name"
    t.string "sport_entry_status", limit: 20, null: false
    t.string "sport_name", limit: 20, null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at"
    t.datetime "failed_at", precision: nil
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "locked_at", precision: nil
    t.string "locked_by"
    t.integer "priority", default: 0, null: false
    t.string "queue"
    t.datetime "run_at", precision: nil
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "event_details", force: :cascade do |t|
    t.text "buddy_comments"
    t.string "buddy_interest", limit: 50
    t.text "camping_rqmts"
    t.integer "caravans", default: 0
    t.datetime "created_at", null: false
    t.integer "estimated_numbers", default: 0
    t.boolean "fire_pit", default: true
    t.bigint "group_id"
    t.string "marquee_co", limit: 50
    t.string "marquee_sizes", limit: 255
    t.integer "marquees", default: 0
    t.integer "number_of_vehicles", default: 0
    t.boolean "onsite", default: true
    t.bigint "orientation_detail_id"
    t.string "orientation_details", limit: 100
    t.string "service_pref_sat", limit: 20, default: "No preference"
    t.string "service_pref_sun", limit: 20, default: "No preference"
    t.integer "tents", default: 0
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.bigint "warden_zone_id"
    t.index ["group_id"], name: "index_event_details_on_group_id"
    t.index ["orientation_detail_id"], name: "index_event_details_on_orientation_detail_id"
  end

  create_table "grades", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.integer "database_rowid"
    t.integer "entries_to_be_allocated", default: 999
    t.integer "entry_limit"
    t.string "gender_type", limit: 10, default: "Open", null: false
    t.string "grade_type", limit: 10, default: "Team", null: false
    t.integer "max_age", default: 29, null: false
    t.integer "max_indiv_entries_group"
    t.integer "max_participants", default: 0, null: false
    t.integer "max_team_entries_group"
    t.integer "min_age", default: 11, null: false
    t.integer "min_females", default: 0, null: false
    t.integer "min_males", default: 0, null: false
    t.integer "min_participants", default: 0, null: false
    t.integer "min_under_18s", default: 0, null: false
    t.string "name", limit: 50, null: false
    t.boolean "one_entry_per_group", default: false
    t.boolean "over_limit", default: false
    t.bigint "sport_id", default: 0, null: false
    t.integer "starting_entry_limit"
    t.string "status", limit: 20, default: "Open", null: false
    t.integer "team_size", default: 1
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.datetime "waitlist_expires_at", precision: nil
    t.index ["name"], name: "index_grades_on_name", unique: true
  end

  create_table "group_extras", force: :cascade do |t|
    t.string "comment_prompt"
    t.decimal "cost", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.string "name", limit: 20, null: false
    t.boolean "needs_size", default: false
    t.boolean "optional", default: true
    t.boolean "show_comment", default: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_extras_on_group_id"
  end

  create_table "group_fee_categories", force: :cascade do |t|
    t.string "adjustment_type", limit: 15, default: "Add"
    t.decimal "amount", precision: 8, scale: 2, default: "1.0"
    t.datetime "created_at", null: false
    t.string "description", limit: 40
    t.date "expiry_date"
    t.bigint "group_id", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_fee_categories_on_group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "abbr", limit: 4, null: false
    t.string "address", limit: 200, null: false
    t.boolean "admin_use", default: false
    t.string "age_demographic", limit: 40
    t.integer "allocation_bonus", default: 0
    t.text "attendee_profile"
    t.boolean "coming", default: true
    t.datetime "created_at", null: false
    t.integer "database_rowid"
    t.string "denomination", limit: 40, null: false
    t.string "email", limit: 100
    t.text "gc_decision"
    t.text "gc_role"
    t.text "gc_thoughts"
    t.integer "gc_years_attended_church"
    t.text "group_changes"
    t.string "group_focus", limit: 100
    t.boolean "last_year", default: false
    t.decimal "late_fees", precision: 8, scale: 2, default: "0.0"
    t.integer "lock_version", default: 0
    t.text "ministry_goal"
    t.string "name", limit: 100, null: false
    t.boolean "new_group", default: true
    t.string "phone_number", limit: 20
    t.integer "postcode", null: false
    t.string "reference_caller", limit: 20
    t.text "reference_notes"
    t.string "short_name", limit: 50, null: false
    t.string "status", limit: 12, default: "Stale"
    t.string "suburb", limit: 40, null: false
    t.string "ticket_email", limit: 100
    t.string "ticket_preference", limit: 20, default: "Send to GC"
    t.string "trading_name", limit: 100, null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.string "website", limit: 100
    t.integer "years_attended", default: 0
    t.index ["abbr"], name: "index_groups_on_abbr", unique: true
    t.index ["name"], name: "index_groups_on_name", unique: true
    t.index ["short_name"], name: "index_groups_on_short_name", unique: true
    t.index ["trading_name"], name: "index_groups_on_trading_name", unique: true
  end

  create_table "groups_sports_filters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.bigint "sport_id", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_groups_sports_filters_on_group_id"
    t.index ["sport_id"], name: "index_groups_sports_filters_on_sport_id"
  end

  create_table "groups_users", id: false, force: :cascade do |t|
    t.bigint "group_id"
    t.bigint "user_id"
    t.index ["group_id"], name: "index_groups_users_on_group_id"
    t.index ["user_id"], name: "index_groups_users_on_user_id"
  end

  create_table "lost_items", force: :cascade do |t|
    t.string "address", limit: 200
    t.string "category", limit: 30, null: false
    t.boolean "claimed", default: false
    t.datetime "created_at", null: false
    t.string "description", limit: 255, null: false
    t.string "email", limit: 100
    t.integer "lock_version", default: 0
    t.string "name", limit: 40
    t.text "notes"
    t.string "phone_number", limit: 30
    t.integer "postcode"
    t.string "suburb", limit: 40
    t.datetime "updated_at", null: false
  end

  create_table "mysyg_settings", force: :cascade do |t|
    t.string "address_option", limit: 10, default: "Show"
    t.string "allergy_option", limit: 10, default: "Show"
    t.boolean "allow_offsite", default: true
    t.boolean "allow_part_time", default: true
    t.string "approve_option", default: "Normal"
    t.string "collect_age_by", limit: 20, default: "Age"
    t.datetime "created_at", null: false
    t.string "dietary_option", limit: 10, default: "Show"
    t.decimal "extra_fee_per_day", precision: 8, scale: 2, default: "0.0"
    t.decimal "extra_fee_total", precision: 8, scale: 2, default: "0.0"
    t.bigint "group_id"
    t.string "indiv_sport_view_strategy", default: "Show all"
    t.string "medical_option", limit: 10, default: "Show"
    t.string "medicare_option", limit: 10, default: "Show"
    t.string "mysyg_code", limit: 25
    t.boolean "mysyg_enabled", default: false
    t.string "mysyg_name", limit: 50
    t.boolean "mysyg_open", default: false
    t.text "participant_instructions"
    t.boolean "require_emerg_contact", default: false
    t.boolean "require_medical", default: false
    t.boolean "show_finance_in_mysyg", default: true
    t.boolean "show_group_extras_in_mysyg", default: true
    t.boolean "show_sports_in_mysyg", default: true
    t.boolean "show_sports_on_signup", default: false
    t.boolean "show_volunteers_in_mysyg", default: true
    t.string "team_sport_view_strategy", default: "Show all"
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_mysyg_settings_on_group_id"
  end

  create_table "orientation_details", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "event_date_time"
    t.string "name", limit: 20
    t.datetime "updated_at", null: false
    t.string "venue_address"
    t.string "venue_name"
  end

  create_table "pages", force: :cascade do |t|
    t.boolean "admin_use"
    t.datetime "created_at", null: false
    t.string "name", limit: 50
    t.string "permalink", limit: 20
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_pages_on_name", unique: true
    t.index ["permalink"], name: "index_pages_on_permalink", unique: true
  end

  create_table "participant_extras", force: :cascade do |t|
    t.string "comment", limit: 255
    t.datetime "created_at", null: false
    t.bigint "group_extra_id", null: false
    t.bigint "participant_id", null: false
    t.string "size", limit: 10
    t.datetime "updated_at", null: false
    t.boolean "wanted", default: false
    t.index ["group_extra_id"], name: "index_participant_extras_on_group_extra_id"
    t.index ["participant_id"], name: "index_participant_extras_on_participant_id"
  end

  create_table "participants", force: :cascade do |t|
    t.string "address", limit: 200
    t.integer "age", default: 30, null: false
    t.string "allergies", limit: 255
    t.decimal "amount_paid", precision: 8, scale: 2, default: "0.0"
    t.string "booking_nbr", limit: 10
    t.boolean "coming", default: true
    t.boolean "coming_friday", default: true
    t.boolean "coming_monday", default: true
    t.boolean "coming_saturday", default: true
    t.boolean "coming_sunday", default: true
    t.datetime "created_at", null: false
    t.integer "database_rowid"
    t.date "date_of_birth"
    t.string "dietary_requirements", limit: 255
    t.boolean "dirty", default: false
    t.boolean "driver", default: false
    t.boolean "driver_signature", default: false
    t.datetime "driver_signature_date", precision: nil
    t.boolean "early_bird", default: false
    t.string "email", limit: 100
    t.string "emergency_contact", limit: 40
    t.string "emergency_email", limit: 100
    t.string "emergency_phone_number", limit: 20
    t.string "emergency_relationship", limit: 20
    t.boolean "exported", default: false
    t.decimal "fee_when_withdrawn", precision: 8, scale: 2, default: "0.0"
    t.string "first_name", limit: 20, null: false
    t.string "gender", limit: 1, default: "M", null: false
    t.boolean "group_coord", default: false
    t.bigint "group_fee_category_id"
    t.bigint "group_id", default: 0, null: false
    t.boolean "guest", default: false
    t.boolean "helper", default: false
    t.boolean "late_fee_charged", default: false
    t.string "licence_type", limit: 15
    t.integer "lock_version", default: 0
    t.string "medical_info", limit: 255
    t.text "medical_injuries"
    t.date "medicare_expiry"
    t.string "medicare_number"
    t.string "medications", limit: 255
    t.string "mobile_phone_number", limit: 20
    t.string "number_plate", limit: 10
    t.boolean "onsite", default: true
    t.boolean "paid", default: false
    t.integer "postcode"
    t.string "registration_nbr", limit: 24
    t.string "rego_type", limit: 10, default: "Full Time"
    t.boolean "spectator", default: false
    t.boolean "sport_coord", default: false
    t.string "status", limit: 20, default: "Accepted"
    t.string "suburb", limit: 40
    t.string "surname", limit: 20, null: false
    t.string "transfer_email", limit: 100
    t.string "transfer_token"
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.boolean "vaccinated", default: false
    t.string "vaccination_document", limit: 40
    t.string "vaccination_sighted_by", limit: 20
    t.bigint "voucher_id"
    t.boolean "withdrawn", default: false
    t.string "wwcc_number"
    t.integer "years_attended"
    t.index ["coming"], name: "index_participants_on_coming"
    t.index ["group_fee_category_id"], name: "index_participants_on_group_fee_category_id"
    t.index ["group_id", "surname", "first_name"], name: "index_participants_on_group_id_and_surname_and_first_name", unique: true
    t.index ["surname", "first_name"], name: "index_participants_on_surname_and_first_name"
    t.index ["transfer_token"], name: "index_participants_on_transfer_token"
    t.index ["voucher_id"], name: "index_participants_on_voucher_id"
  end

  create_table "participants_sport_entries", id: false, force: :cascade do |t|
    t.bigint "participant_id", null: false
    t.bigint "sport_entry_id", null: false
  end

  create_table "participants_users", id: false, force: :cascade do |t|
    t.bigint "participant_id", null: false
    t.bigint "user_id", null: false
    t.index ["participant_id"], name: "index_participants_users_on_participant_id"
    t.index ["user_id"], name: "index_participants_users_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 8, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.string "invoice_type", limit: 20, default: "Unspecified", null: false
    t.string "name", limit: 50
    t.boolean "paid", default: false
    t.datetime "paid_at"
    t.string "payment_type", limit: 20, null: false
    t.boolean "reconciled", default: false
    t.string "reference", limit: 50
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.index ["group_id"], name: "index_payments_on_group_id"
  end

  create_table "question_options", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "order_number", default: 1
    t.bigint "question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_question_options_on_question_id"
  end

  create_table "question_responses", force: :cascade do |t|
    t.text "answer"
    t.datetime "created_at", null: false
    t.bigint "participant_id", null: false
    t.bigint "question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_id"], name: "index_question_responses_on_participant_id"
    t.index ["question_id"], name: "index_question_responses_on_question_id"
  end

  create_table "questions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "group_id", null: false
    t.string "name", limit: 50, null: false
    t.integer "order_number", default: 1
    t.string "question_type", limit: 20, null: false
    t.boolean "required", default: false
    t.string "section", limit: 20, null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "section", "order_number"], name: "index_questions_on_group_id_and_section_and_order_number"
    t.index ["group_id"], name: "index_questions_on_group_id"
  end

  create_table "rego_checklists", force: :cascade do |t|
    t.string "admin_rep", limit: 40
    t.boolean "covid_plan_sighted", default: false
    t.datetime "created_at", null: false
    t.text "disabled_notes"
    t.boolean "disabled_participants", default: false
    t.boolean "driver_form", default: false
    t.text "driving_notes"
    t.text "finance_notes"
    t.boolean "food_cert_sighted", default: false
    t.bigint "group_id"
    t.boolean "insurance_sighted", default: false
    t.boolean "registered", default: false
    t.string "rego_mobile", limit: 30
    t.string "rego_rep", limit: 40
    t.string "second_mobile", limit: 30
    t.string "second_rep", limit: 40
    t.string "site_check_church_contact"
    t.datetime "site_check_completed_at"
    t.string "site_check_completed_by"
    t.boolean "site_check_electrical_1", default: false
    t.boolean "site_check_electrical_2", default: false
    t.boolean "site_check_electrical_3", default: false
    t.boolean "site_check_electrical_4", default: false
    t.boolean "site_check_electrical_5", default: false
    t.boolean "site_check_electrical_6", default: false
    t.boolean "site_check_electrical_7", default: false
    t.boolean "site_check_electrical_8", default: false
    t.boolean "site_check_fire_1", default: false
    t.boolean "site_check_fire_2", default: false
    t.boolean "site_check_fire_3", default: false
    t.boolean "site_check_fire_4", default: false
    t.boolean "site_check_flames_1", default: false
    t.boolean "site_check_flames_2", default: false
    t.boolean "site_check_flames_3", default: false
    t.boolean "site_check_flames_4", default: false
    t.boolean "site_check_flames_5", default: false
    t.boolean "site_check_flames_6", default: false
    t.boolean "site_check_flames_7"
    t.boolean "site_check_food_1", default: false
    t.boolean "site_check_food_2", default: false
    t.boolean "site_check_food_3", default: false
    t.boolean "site_check_food_4"
    t.boolean "site_check_gas_1", default: false
    t.boolean "site_check_gas_2", default: false
    t.boolean "site_check_medical_1", default: false
    t.boolean "site_check_medical_2", default: false
    t.boolean "site_check_medical_3", default: false
    t.boolean "site_check_medical_4", default: false
    t.boolean "site_check_medical_5", default: false
    t.boolean "site_check_medical_6", default: false
    t.boolean "site_check_medical_7"
    t.string "site_check_notes"
    t.text "site_check_onsite_notes"
    t.boolean "site_check_safety_1", default: false
    t.boolean "site_check_safety_2", default: false
    t.boolean "site_check_safety_3", default: false
    t.boolean "site_check_safety_4", default: false
    t.boolean "site_check_safety_5", default: false
    t.boolean "site_check_safety_6"
    t.boolean "site_check_site_1", default: false
    t.boolean "site_check_site_2", default: false
    t.string "site_check_status", limit: 20, default: "Not completed"
    t.text "sport_notes"
    t.datetime "updated_at", null: false
    t.text "upload_notes"
    t.index ["group_id"], name: "index_rego_checklists_on_group_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "group_related", default: false
    t.string "name", limit: 20
    t.boolean "participant_related", default: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "user_id"
    t.index ["role_id"], name: "index_roles_users_on_role_id"
    t.index ["user_id"], name: "index_roles_users_on_user_id"
  end

  create_table "round_robin_matches", force: :cascade do |t|
    t.boolean "complete", default: false
    t.integer "court", default: 1
    t.datetime "created_at", null: false
    t.bigint "draw_number"
    t.bigint "entry_a_id"
    t.bigint "entry_b_id"
    t.bigint "entry_umpire_id"
    t.boolean "forfeit_a", default: false
    t.boolean "forfeit_b", default: false
    t.boolean "forfeit_umpire", default: false
    t.integer "match"
    t.integer "score_a", default: 0
    t.integer "score_b", default: 0
    t.bigint "section_id"
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.index ["draw_number"], name: "index_round_robin_matches_on_draw_number"
    t.index ["entry_a_id"], name: "index_round_robin_matches_on_entry_a_id"
    t.index ["entry_b_id"], name: "index_round_robin_matches_on_entry_b_id"
    t.index ["entry_umpire_id"], name: "index_round_robin_matches_on_entry_umpire_id"
    t.index ["section_id"], name: "index_round_robin_matches_on_section_id"
  end

  create_table "sections", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.integer "database_rowid"
    t.string "draw_type", limit: 20, default: "Round Robin", null: false
    t.string "finals_format", limit: 20
    t.bigint "grade_id", default: 0, null: false
    t.string "name", limit: 50, null: false
    t.integer "number_in_draw"
    t.integer "number_of_courts", default: 1
    t.integer "number_of_groups", default: 1
    t.boolean "results_locked", default: false
    t.bigint "session_id", default: 0, null: false
    t.integer "start_court", default: 1
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.bigint "venue_id", default: 0, null: false
    t.integer "year_introduced"
    t.index ["name"], name: "index_sections_on_name", unique: true
  end

  create_table "sections_volunteers", id: false, force: :cascade do |t|
    t.bigint "section_id", null: false
    t.bigint "volunteer_id", null: false
    t.index ["section_id"], name: "index_sections_volunteers_on_section_id"
    t.index ["volunteer_id"], name: "index_sections_volunteers_on_volunteer_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.integer "database_rowid"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.index ["database_rowid"], name: "index_sessions_on_database_rowid", unique: true
    t.index ["name"], name: "index_sessions_on_name", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "admin_email", limit: 100, default: ""
    t.boolean "allow_gc_to_add_participants", default: false
    t.string "comms_email", limit: 100, default: ""
    t.decimal "coordinator_adjustment", precision: 8, scale: 2, default: "0.5", null: false
    t.datetime "created_at", null: false
    t.decimal "daily_adjustment", precision: 8, scale: 2, default: "0.55", null: false
    t.decimal "day_visitor_adjustment", precision: 8, scale: 2, default: "1.0", null: false
    t.date "deposit_due_date"
    t.boolean "early_bird", default: false
    t.date "early_bird_cutoff"
    t.decimal "early_bird_discount", precision: 8, scale: 2, default: "10.0", null: false
    t.boolean "evening_sessions_final", default: false
    t.string "finance_email", limit: 100, default: ""
    t.date "first_day_of_syg"
    t.decimal "full_fee", precision: 8, scale: 2, default: "109.0", null: false
    t.string "gc_feedback_url"
    t.boolean "generate_stats", default: false
    t.boolean "group_registrations_closed", default: false
    t.decimal "helper_adjustment", precision: 8, scale: 2, default: "0.55", null: false
    t.string "incident_link", default: ""
    t.boolean "indiv_draws_complete", default: false
    t.string "info_email", limit: 100, default: ""
    t.string "lost_property_email", limit: 100, default: ""
    t.integer "medium_division_ceiling", default: 40
    t.integer "missed_out_sports_allocation_factor", default: 0
    t.integer "new_group_sports_allocation_factor", default: 0
    t.string "participant_feedback_url"
    t.boolean "participant_registrations_closed", default: false
    t.decimal "primary_age_adjustment", precision: 8, scale: 2, default: "0.0", null: false
    t.string "public_website", default: ""
    t.string "rego_email", limit: 100, default: ""
    t.string "rego_website", default: ""
    t.boolean "restricted_sports_allocated", default: false
    t.integer "small_division_ceiling", default: 20
    t.string "social_facebook_gc_url", default: ""
    t.string "social_facebook_url", default: ""
    t.string "social_instagram_url", default: ""
    t.string "social_spotify_url", default: ""
    t.string "social_twitter_url", default: ""
    t.string "social_youtube_url", default: ""
    t.decimal "spectator_adjustment", precision: 8, scale: 2, default: "0.77", null: false
    t.integer "sport_coord_sports_allocation_factor", default: 0
    t.string "sports_admin_email", limit: 100, default: ""
    t.string "sports_email", limit: 100, default: ""
    t.boolean "sports_loaded", default: false
    t.boolean "syg_is_finished", default: false
    t.boolean "syg_is_happening", default: false
    t.boolean "team_draws_complete", default: false
    t.integer "this_year", default: 1991
    t.string "ticket_email", limit: 100, default: ""
    t.datetime "updated_at", null: false
    t.boolean "updates_restricted", default: false
    t.boolean "volunteers_loaded", default: false
    t.string "website_host", default: ""
  end

  create_table "sport_entries", force: :cascade do |t|
    t.bigint "captaincy_id"
    t.integer "chance_of_entry", default: 100
    t.datetime "created_at", null: false
    t.bigint "grade_id", null: false
    t.bigint "group_id", null: false
    t.integer "group_number", default: 1
    t.boolean "multiple_teams", default: false
    t.bigint "preferred_section_id"
    t.bigint "section_id"
    t.string "status", limit: 20, default: "Requested"
    t.integer "team_number", default: 1, null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.index ["grade_id"], name: "index_sport_entries_on_grade_id"
    t.index ["group_id"], name: "index_sport_entries_on_group_id"
  end

  create_table "sport_preferences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "level", limit: 100
    t.bigint "participant_id", null: false
    t.integer "preference"
    t.bigint "sport_id"
    t.datetime "updated_at", null: false
    t.index ["participant_id"], name: "index_sport_preferences_on_participant_id"
    t.index ["sport_id"], name: "index_sport_preferences_on_sport_id"
  end

  create_table "sports", force: :cascade do |t|
    t.boolean "active", default: true
    t.boolean "allow_negative_score", default: false
    t.boolean "blowout_rule", default: false
    t.string "classification", limit: 10, null: false
    t.string "court_name", limit: 20, default: "Court"
    t.datetime "created_at", null: false
    t.integer "forfeit_score", default: 0
    t.string "ladder_tie_break", limit: 20, default: "Percentage"
    t.integer "max_entries_indiv", default: 0, null: false
    t.integer "max_indiv_entries_group", default: 0, null: false
    t.integer "max_team_entries_group", default: 0, null: false
    t.string "name", limit: 20, null: false
    t.string "point_name", limit: 20, default: "Point"
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.index ["name"], name: "index_sports_on_name", unique: true
  end

  create_table "sports_evaluations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "equipment_rating", null: false
    t.string "length_rating", null: false
    t.string "results_rating", null: false
    t.string "safety_rating", null: false
    t.string "scoring_rating", null: false
    t.string "section", limit: 50, null: false
    t.string "session", limit: 50, null: false
    t.string "sport", limit: 20, null: false
    t.text "suggestions"
    t.string "support_rating", null: false
    t.string "time_rating", null: false
    t.text "to_improve"
    t.string "umpiring_rating", null: false
    t.datetime "updated_at", null: false
    t.string "venue_rating", limit: 10, null: false
    t.text "worked_well"
    t.index ["section"], name: "index_sports_evaluations_on_section"
  end

  create_table "statistics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "number_of_groups"
    t.integer "number_of_participants"
    t.integer "number_of_sport_entries"
    t.integer "number_of_volunteer_vacancies"
    t.datetime "updated_at", null: false
    t.integer "weeks_to_syg"
    t.integer "year", default: 2022
  end

  create_table "timelines", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", limit: 255
    t.date "key_date", null: false
    t.string "name", limit: 50
    t.datetime "updated_at", null: false
    t.index ["key_date", "name"], name: "index_timelines_on_key_date_and_name"
  end

  create_table "users", force: :cascade do |t|
    t.string "address", limit: 200
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "gc_reference", limit: 40
    t.string "gc_reference_phone", limit: 30
    t.string "group_role", limit: 100
    t.string "name", limit: 40, default: "", null: false
    t.string "phone_number", limit: 30
    t.integer "postcode", default: 0
    t.boolean "primary_gc", default: false
    t.boolean "protect_password", default: false
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.string "status", limit: 12, default: "Not Verified"
    t.string "suburb", limit: 40
    t.datetime "updated_at", null: false
    t.string "wwcc_number"
    t.integer "years_as_gc", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "venues", force: :cascade do |t|
    t.boolean "active"
    t.string "address"
    t.datetime "created_at", null: false
    t.string "database_code", limit: 4
    t.string "name", limit: 50, default: "", null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.index ["database_code"], name: "index_venues_on_database_code", unique: true
    t.index ["name"], name: "index_venues_on_name", unique: true
  end

  create_table "volunteer_types", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "age_category", limit: 20, default: "Over 18"
    t.string "cc_email", limit: 100
    t.datetime "created_at", null: false
    t.string "database_code", limit: 4
    t.text "description"
    t.string "email_template", limit: 20, default: "Default"
    t.string "name", limit: 100, null: false
    t.boolean "send_volunteer_email", default: false
    t.boolean "sport_related", default: false
    t.boolean "t_shirt", default: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.index ["name"], name: "index_volunteer_types_on_name", unique: true
  end

  create_table "volunteers", force: :cascade do |t|
    t.string "cc_email", limit: 100
    t.boolean "collected", default: false
    t.datetime "created_at", null: false
    t.string "description", limit: 100, null: false
    t.boolean "details_confirmed", default: false
    t.string "email", limit: 100
    t.boolean "email_sent", default: false
    t.string "email_strategy", limit: 20, default: "As defined in type"
    t.string "email_template", limit: 20, default: "Default"
    t.string "equipment_in"
    t.string "equipment_out"
    t.integer "lock_version", default: 0
    t.boolean "mobile_confirmed", default: false
    t.string "mobile_number", limit: 20
    t.text "notes"
    t.bigint "participant_id"
    t.boolean "returned", default: false
    t.boolean "send_volunteer_email", default: false
    t.bigint "session_id"
    t.string "t_shirt_size", limit: 10
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.bigint "volunteer_type_id"
    t.index ["participant_id"], name: "index_volunteers_on_participant_id"
    t.index ["volunteer_type_id"], name: "index_volunteers_on_volunteer_type_id"
  end

  create_table "vouchers", force: :cascade do |t|
    t.decimal "adjustment", precision: 8, scale: 2, default: "1.0", null: false
    t.datetime "created_at", null: false
    t.datetime "expiry"
    t.bigint "group_id"
    t.integer "limit", default: 1
    t.string "name", limit: 20, null: false
    t.string "restricted_to", limit: 20
    t.datetime "updated_at", null: false
    t.string "voucher_type", limit: 15, default: "Multiply", null: false
    t.index ["group_id"], name: "index_vouchers_on_group_id"
  end

  create_table "warden_zones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "warden_info"
    t.integer "zone"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "event_details", "groups"
  add_foreign_key "event_details", "orientation_details"
  add_foreign_key "grades", "sports"
  add_foreign_key "group_extras", "groups"
  add_foreign_key "group_fee_categories", "groups"
  add_foreign_key "groups_sports_filters", "groups"
  add_foreign_key "groups_sports_filters", "sports"
  add_foreign_key "groups_users", "groups"
  add_foreign_key "groups_users", "users"
  add_foreign_key "mysyg_settings", "groups"
  add_foreign_key "participant_extras", "group_extras"
  add_foreign_key "participant_extras", "participants"
  add_foreign_key "participants", "groups"
  add_foreign_key "participants_users", "participants"
  add_foreign_key "participants_users", "users"
  add_foreign_key "payments", "groups"
  add_foreign_key "question_options", "questions"
  add_foreign_key "question_responses", "participants"
  add_foreign_key "question_responses", "questions"
  add_foreign_key "questions", "groups"
  add_foreign_key "rego_checklists", "groups"
  add_foreign_key "roles_users", "roles"
  add_foreign_key "roles_users", "users"
  add_foreign_key "sections", "grades"
  add_foreign_key "sections", "sessions"
  add_foreign_key "sections", "venues"
  add_foreign_key "sections_volunteers", "sections"
  add_foreign_key "sections_volunteers", "volunteers"
  add_foreign_key "sport_entries", "grades"
  add_foreign_key "sport_entries", "groups"
  add_foreign_key "sport_preferences", "participants"
  add_foreign_key "sport_preferences", "sports"
  add_foreign_key "volunteers", "volunteer_types"
end
