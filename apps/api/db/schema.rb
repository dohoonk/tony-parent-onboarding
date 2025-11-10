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

ActiveRecord::Schema[8.0].define(version: 2025_11_10_000025) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "appointment_status", ["scheduled", "confirmed", "completed", "cancelled", "no_show"]
  create_enum "message_role", ["user", "assistant", "system"]
  create_enum "onboarding_status", ["draft", "active", "completed", "abandoned"]
  create_enum "organization_kind", ["district", "school"]

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
    t.jsonb "availability_json", default: {}
    t.string "timezone"
    t.index ["availability_json"], name: "index_availability_windows_on_availability_json", using: :gin
    t.index ["owner_type", "owner_id"], name: "index_availability_windows_on_owner_type_and_owner_id"
    t.index ["start_date"], name: "index_availability_windows_on_start_date"
    t.index ["timezone"], name: "index_availability_windows_on_timezone"
  end

  create_table "clinician_credentialed_insurances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "care_provider_profile_id", null: false
    t.uuid "credentialed_insurance_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["care_provider_profile_id", "credentialed_insurance_id"], name: "index_clinician_cred_ins_on_therapist_and_insurance", unique: true
    t.index ["care_provider_profile_id"], name: "index_clinician_cred_ins_on_therapist_id"
    t.index ["created_at"], name: "index_clinician_credentialed_insurances_on_created_at"
    t.index ["credentialed_insurance_id"], name: "idx_on_credentialed_insurance_id_3668f7d2e3"
  end

  create_table "contracts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "effective_date", null: false
    t.date "end_date"
    t.text "services", default: [], array: true
    t.jsonb "terms", default: {}
    t.string "contract_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_contracts_on_created_at"
    t.index ["effective_date", "end_date"], name: "index_contracts_on_effective_date_and_end_date"
    t.index ["effective_date"], name: "index_contracts_on_effective_date"
    t.index ["end_date"], name: "index_contracts_on_end_date"
    t.index ["services"], name: "index_contracts_on_services", using: :gin
    t.index ["terms"], name: "index_contracts_on_terms", using: :gin
  end

  create_table "cost_estimates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "onboarding_session_id", null: false
    t.integer "min_cost_cents", null: false
    t.integer "max_cost_cents", null: false
    t.string "basis"
    t.datetime "created_at", precision: nil, null: false
    t.index ["onboarding_session_id"], name: "index_cost_estimates_on_onboarding_session_id", unique: true
  end

  create_table "credentialed_insurances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "parent_credentialed_insurance_id"
    t.string "name", null: false
    t.string "country", default: "US"
    t.string "state"
    t.string "line_of_business"
    t.text "legacy_names", default: [], array: true
    t.string "open_pm_name"
    t.integer "network_status", default: 0
    t.boolean "associates_allowed", default: false
    t.string "legacy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country", "state"], name: "index_credentialed_insurances_on_country_and_state"
    t.index ["created_at"], name: "index_credentialed_insurances_on_created_at"
    t.index ["legacy_names"], name: "index_credentialed_insurances_on_legacy_names", using: :gin
    t.index ["name", "state"], name: "index_credentialed_insurances_on_name_and_state"
    t.index ["name"], name: "index_credentialed_insurances_on_name"
    t.index ["network_status"], name: "index_credentialed_insurances_on_network_status"
    t.index ["parent_credentialed_insurance_id", "network_status"], name: "idx_on_parent_credentialed_insurance_id_network_sta_1b073221cf"
    t.index ["parent_credentialed_insurance_id"], name: "idx_on_parent_credentialed_insurance_id_1bfe213fc2"
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

  create_table "org_contracts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "contract_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_org_contracts_on_contract_id"
    t.index ["created_at"], name: "index_org_contracts_on_created_at"
    t.index ["organization_id", "contract_id"], name: "index_org_contracts_on_organization_id_and_contract_id", unique: true
    t.index ["organization_id"], name: "index_org_contracts_on_organization_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "parent_organization_id"
    t.enum "kind", null: false, enum_type: "organization_kind"
    t.string "slug", null: false
    t.string "name", null: false
    t.string "internal_name"
    t.string "tzdb"
    t.uuid "market_id"
    t.jsonb "config", default: {}
    t.datetime "enabled_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["config"], name: "index_organizations_on_config", using: :gin
    t.index ["created_at"], name: "index_organizations_on_created_at"
    t.index ["enabled_at"], name: "index_organizations_on_enabled_at"
    t.index ["kind", "parent_organization_id"], name: "index_organizations_on_kind_and_parent_organization_id"
    t.index ["kind"], name: "index_organizations_on_kind"
    t.index ["market_id"], name: "index_organizations_on_market_id"
    t.index ["parent_organization_id", "enabled_at"], name: "index_organizations_on_parent_organization_id_and_enabled_at"
    t.index ["parent_organization_id"], name: "index_organizations_on_parent_organization_id"
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
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

  create_table "referral_members", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "referral_id", null: false
    t.uuid "user_id", null: false
    t.string "user_type", null: false
    t.integer "role"
    t.jsonb "data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_referral_members_on_created_at"
    t.index ["data"], name: "index_referral_members_on_data", using: :gin
    t.index ["referral_id", "user_id", "user_type"], name: "index_referral_members_unique", unique: true
    t.index ["referral_id"], name: "index_referral_members_on_referral_id"
    t.index ["role"], name: "index_referral_members_on_role"
    t.index ["user_id", "user_type"], name: "index_referral_members_on_user_id_and_user_type"
  end

  create_table "referrals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "submitter_id", null: false
    t.uuid "organization_id", null: false
    t.uuid "contract_id"
    t.uuid "intake_id"
    t.uuid "care_provider_id"
    t.integer "service_kind"
    t.text "concerns"
    t.jsonb "data", default: {}
    t.integer "terms_kind"
    t.integer "appointment_kind"
    t.integer "planned_sessions"
    t.integer "initial_scheduled_sessions"
    t.boolean "collect_coverage", default: false
    t.text "allowed_coverage", default: [], array: true
    t.integer "collection_rule"
    t.boolean "self_responsibility_required", default: false
    t.text "care_provider_requirements", default: [], array: true
    t.datetime "referred_at", precision: nil
    t.datetime "ready_for_scheduling_at", precision: nil
    t.datetime "scheduled_at", precision: nil
    t.datetime "onboarding_completed_at", precision: nil
    t.datetime "enrolled_at", precision: nil
    t.datetime "disenrolled_at", precision: nil
    t.datetime "request_rejected_at", precision: nil
    t.datetime "excluded_at", precision: nil
    t.text "system_labels", default: [], array: true
    t.string "tzdb"
    t.text "notes"
    t.string "disenrollment_category"
    t.string "zendesk_ticket_id"
    t.uuid "market_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["allowed_coverage"], name: "index_referrals_on_allowed_coverage", using: :gin
    t.index ["care_provider_id"], name: "index_referrals_on_care_provider_id"
    t.index ["care_provider_requirements"], name: "index_referrals_on_care_provider_requirements", using: :gin
    t.index ["contract_id"], name: "index_referrals_on_contract_id"
    t.index ["created_at"], name: "index_referrals_on_created_at"
    t.index ["data"], name: "index_referrals_on_data", using: :gin
    t.index ["enrolled_at"], name: "index_referrals_on_enrolled_at"
    t.index ["intake_id"], name: "index_referrals_on_intake_id"
    t.index ["organization_id", "referred_at"], name: "index_referrals_on_organization_id_and_referred_at"
    t.index ["organization_id"], name: "index_referrals_on_organization_id"
    t.index ["referred_at"], name: "index_referrals_on_referred_at"
    t.index ["scheduled_at"], name: "index_referrals_on_scheduled_at"
    t.index ["service_kind"], name: "index_referrals_on_service_kind"
    t.index ["submitter_id", "created_at"], name: "index_referrals_on_submitter_id_and_created_at"
    t.index ["submitter_id"], name: "index_referrals_on_submitter_id"
    t.index ["system_labels"], name: "index_referrals_on_system_labels", using: :gin
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

  create_table "therapists", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "healthie_id"
    t.string "email"
    t.string "phone"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "preferred_name"
    t.string "preferred_pronoun"
    t.string "title"
    t.date "birthdate"
    t.string "preferred_language", default: "en"
    t.string "legal_gender"
    t.string "standardized_gender"
    t.string "self_gender"
    t.string "gender_identity"
    t.string "ethnicity"
    t.text "ethnicity_and_demographics", default: [], array: true
    t.string "primary_ethnicity"
    t.string "primary_ethnicity_code"
    t.string "primary_race"
    t.string "primary_race_code"
    t.text "religions", default: [], array: true
    t.string "standardized_sexual_orientation"
    t.string "self_sexual_orientation"
    t.string "sexual_orientation"
    t.string "sexual_orientation_code"
    t.string "npi_number"
    t.text "licenses", default: [], array: true
    t.text "licensed_states", default: [], array: true
    t.string "primary_state"
    t.text "states_active", default: [], array: true
    t.text "specialties", default: [], array: true
    t.text "modalities", default: [], array: true
    t.text "care_languages", default: [], array: true
    t.string "employment_type"
    t.string "clinical_role"
    t.string "care_provider_role"
    t.string "care_provider_status"
    t.boolean "clinical_associate", default: false
    t.boolean "is_super_admin", default: false
    t.text "bio"
    t.jsonb "profile_data", default: {}
    t.uuid "supervisor_id"
    t.uuid "associate_supervisor_id"
    t.integer "capacity_total", default: 0
    t.integer "capacity_filled", default: 0
    t.integer "capacity_available", default: 0
    t.integer "capacity_total_daybreak", default: 0
    t.integer "capacity_filled_daybreak", default: 0
    t.integer "capacity_available_daybreak", default: 0
    t.integer "capacity_total_kaiser", default: 0
    t.integer "capacity_filled_kaiser", default: 0
    t.integer "capacity_available_kaiser", default: 0
    t.string "account_status"
    t.text "system_labels", default: [], array: true
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_therapists_on_active"
    t.index ["care_languages"], name: "index_therapists_on_care_languages", using: :gin
    t.index ["clinical_role"], name: "index_therapists_on_clinical_role"
    t.index ["created_at"], name: "index_therapists_on_created_at"
    t.index ["email"], name: "index_therapists_on_email"
    t.index ["employment_type", "active"], name: "index_therapists_on_employment_type_and_active"
    t.index ["employment_type"], name: "index_therapists_on_employment_type"
    t.index ["healthie_id"], name: "index_therapists_on_healthie_id"
    t.index ["licensed_states"], name: "index_therapists_on_licensed_states", using: :gin
    t.index ["npi_number"], name: "index_therapists_on_npi_number"
    t.index ["primary_state", "active"], name: "index_therapists_on_primary_state_and_active"
    t.index ["primary_state"], name: "index_therapists_on_primary_state"
    t.index ["profile_data"], name: "index_therapists_on_profile_data", using: :gin
    t.index ["specialties"], name: "index_therapists_on_specialties", using: :gin
    t.index ["supervisor_id"], name: "index_therapists_on_supervisor_id"
  end

  add_foreign_key "appointments", "onboarding_sessions"
  add_foreign_key "appointments", "students"
  add_foreign_key "appointments", "therapists"
  add_foreign_key "clinician_credentialed_insurances", "credentialed_insurances"
  add_foreign_key "clinician_credentialed_insurances", "therapists", column: "care_provider_profile_id"
  add_foreign_key "cost_estimates", "onboarding_sessions"
  add_foreign_key "credentialed_insurances", "credentialed_insurances", column: "parent_credentialed_insurance_id"
  add_foreign_key "insurance_cards", "onboarding_sessions"
  add_foreign_key "insurance_policies", "onboarding_sessions"
  add_foreign_key "intake_messages", "onboarding_sessions"
  add_foreign_key "intake_summaries", "onboarding_sessions"
  add_foreign_key "onboarding_sessions", "parents"
  add_foreign_key "onboarding_sessions", "students"
  add_foreign_key "org_contracts", "contracts"
  add_foreign_key "org_contracts", "organizations"
  add_foreign_key "organizations", "organizations", column: "parent_organization_id"
  add_foreign_key "referral_members", "referrals"
  add_foreign_key "referrals", "contracts"
  add_foreign_key "referrals", "organizations"
  add_foreign_key "referrals", "parents", column: "submitter_id"
  add_foreign_key "referrals", "therapists", column: "care_provider_id"
  add_foreign_key "screener_responses", "onboarding_sessions"
  add_foreign_key "screener_responses", "screeners"
  add_foreign_key "students", "parents"
  add_foreign_key "therapists", "therapists", column: "associate_supervisor_id"
  add_foreign_key "therapists", "therapists", column: "supervisor_id"
end
