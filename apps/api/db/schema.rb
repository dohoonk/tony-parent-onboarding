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

ActiveRecord::Schema[8.0].define(version: 2025_11_10_000015) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "appointment_status", ["scheduled", "confirmed", "completed", "cancelled", "no_show"]
  create_enum "message_role", ["user", "assistant", "system"]
  create_enum "onboarding_status", ["draft", "active", "completed", "abandoned"]

  create_table "appointments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "onboarding_session_id", null: false
    t.uuid "student_id", null: false
    t.uuid "therapist_id", null: false
    t.datetime "scheduled_at", precision: nil, null: false
    t.integer "duration_minutes", default: 50, null: false
    t.enum "status", default: "scheduled", null: false, enum_type: "appointment_status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["onboarding_session_id"], name: "index_appointments_on_onboarding_session_id"
    t.index ["scheduled_at"], name: "index_appointments_on_scheduled_at"
    t.index ["status"], name: "index_appointments_on_status"
    t.index ["student_id"], name: "index_appointments_on_student_id"
    t.index ["therapist_id"], name: "index_appointments_on_therapist_id"
  end

  create_table "audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "actor_id"
    t.string "actor_type"
    t.string "action", null: false
    t.string "entity_type", null: false
    t.uuid "entity_id", null: false
    t.jsonb "before_json"
    t.jsonb "after_json"
    t.string "ip_address"
    t.text "user_agent"
    t.datetime "created_at", precision: nil, null: false
    t.index ["actor_id"], name: "index_audit_logs_on_actor_id"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["entity_type", "entity_id"], name: "index_audit_logs_on_entity_type_and_entity_id"
  end

  create_table "availability_windows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "owner_type", null: false
    t.uuid "owner_id", null: false
    t.string "rrule"
    t.date "start_date", null: false
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_availability_windows_on_owner_type_and_owner_id"
    t.index ["start_date"], name: "index_availability_windows_on_start_date"
  end

  create_table "cost_estimates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "onboarding_session_id", null: false
    t.integer "min_cost_cents", null: false
    t.integer "max_cost_cents", null: false
    t.string "basis"
    t.datetime "created_at", precision: nil, null: false
    t.index ["onboarding_session_id"], name: "index_cost_estimates_on_onboarding_session_id", unique: true
  end

  create_table "insurance_cards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "onboarding_session_id", null: false
    t.string "front_image_url", null: false
    t.string "back_image_url"
    t.jsonb "ocr_json"
    t.jsonb "confidence_json"
    t.datetime "created_at", precision: nil, null: false
    t.index ["onboarding_session_id"], name: "index_insurance_cards_on_onboarding_session_id"
  end

  create_table "insurance_policies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "onboarding_session_id", null: false
    t.string "payer_name", null: false
    t.string "member_id", null: false
    t.string "group_number"
    t.string "plan_type"
    t.string "subscriber_name"
    t.datetime "verified_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["onboarding_session_id"], name: "index_insurance_policies_on_onboarding_session_id", unique: true
  end

  create_table "intake_messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "onboarding_session_id", null: false
    t.enum "role", null: false, enum_type: "message_role"
    t.text "content", null: false
    t.text "de_identified_content"
    t.datetime "created_at", precision: nil, null: false
    t.index ["created_at"], name: "index_intake_messages_on_created_at"
    t.index ["onboarding_session_id"], name: "index_intake_messages_on_onboarding_session_id"
  end

  create_table "intake_summaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "onboarding_session_id", null: false
    t.jsonb "concerns_json"
    t.jsonb "goals_json"
    t.jsonb "risk_flags_json"
    t.text "summary_text"
    t.datetime "created_at", precision: nil, null: false
    t.index ["onboarding_session_id"], name: "index_intake_summaries_on_onboarding_session_id", unique: true
  end

  create_table "onboarding_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "parent_id", null: false
    t.uuid "student_id", null: false
    t.enum "status", default: "draft", null: false, enum_type: "onboarding_status"
    t.integer "current_step", default: 1, null: false
    t.integer "eta_seconds"
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_onboarding_sessions_on_parent_id"
    t.index ["status"], name: "index_onboarding_sessions_on_status"
    t.index ["student_id"], name: "index_onboarding_sessions_on_student_id"
  end

  create_table "parents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "phone"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "auth_provider", default: "magic_link", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "parent", null: false
    t.index ["created_at"], name: "index_parents_on_created_at"
    t.index ["email"], name: "index_parents_on_email", unique: true
    t.index ["role"], name: "index_parents_on_role"
  end

  create_table "screener_responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "onboarding_session_id", null: false
    t.uuid "screener_id", null: false
    t.jsonb "answers_json", null: false
    t.integer "score"
    t.text "interpretation_text"
    t.datetime "created_at", precision: nil, null: false
    t.index ["onboarding_session_id"], name: "index_screener_responses_on_onboarding_session_id"
    t.index ["screener_id"], name: "index_screener_responses_on_screener_id"
  end

  create_table "screeners", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "title", null: false
    t.string "version", null: false
    t.jsonb "items_json", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_screeners_on_key", unique: true
  end

  create_table "students", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "parent_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.date "date_of_birth", null: false
    t.string "grade"
    t.string "school"
    t.string "language", default: "en", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date_of_birth"], name: "index_students_on_date_of_birth"
    t.index ["parent_id"], name: "index_students_on_parent_id"
  end

  add_foreign_key "appointments", "onboarding_sessions"
  add_foreign_key "appointments", "students"
  add_foreign_key "cost_estimates", "onboarding_sessions"
  add_foreign_key "insurance_cards", "onboarding_sessions"
  add_foreign_key "insurance_policies", "onboarding_sessions"
  add_foreign_key "intake_messages", "onboarding_sessions"
  add_foreign_key "intake_summaries", "onboarding_sessions"
  add_foreign_key "onboarding_sessions", "parents"
  add_foreign_key "onboarding_sessions", "students"
  add_foreign_key "screener_responses", "onboarding_sessions"
  add_foreign_key "screener_responses", "screeners"
  add_foreign_key "students", "parents"
end
