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

ActiveRecord::Schema[8.0].define(version: 2025_10_10_113404) do
  create_table "access_control_systems", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "clocks", force: :cascade do |t|
    t.integer "terminal_id", null: false
    t.string "employee_no", null: false
    t.datetime "clocked_at", null: false
    t.string "event_type", null: false
    t.string "card_no"
    t.json "raw_data"
    t.string "idempotency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clocked_at"], name: "index_clocks_on_clocked_at"
    t.index ["employee_no", "clocked_at"], name: "index_clocks_on_employee_no_and_clocked_at"
    t.index ["employee_no"], name: "index_clocks_on_employee_no"
    t.index ["event_type"], name: "index_clocks_on_event_type"
    t.index ["idempotency_key"], name: "index_clocks_on_idempotency_key", unique: true, where: "idempotency_key IS NOT NULL"
    t.index ["terminal_id", "clocked_at"], name: "index_clocks_on_terminal_id_and_clocked_at"
    t.index ["terminal_id"], name: "index_clocks_on_terminal_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "name", null: false
    t.string "resource_type"
    t.integer "resource_id"
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_permissions_on_name_and_resource", unique: true
    t.index ["resource_type", "resource_id"], name: "index_permissions_on_resource_type_and_resource_id"
  end

  create_table "persons", force: :cascade do |t|
    t.integer "user_id"
    t.string "first_name"
    t.string "last_name"
    t.string "employee_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_no"], name: "index_persons_on_employee_no", unique: true
    t.index ["user_id"], name: "index_persons_on_user_id"
  end

  create_table "role_permissions", force: :cascade do |t|
    t.integer "role_id", null: false
    t.integer "permission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id", "permission_id"], name: "index_role_permissions_on_role_id_and_permission_id", unique: true
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "resource_type"
    t.integer "resource_id"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", unique: true
    t.index ["name"], name: "index_roles_on_name", unique: true
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "terminals", force: :cascade do |t|
    t.string "name", null: false
    t.string "provider", default: "hikvision", null: false
    t.string "ip", null: false
    t.integer "port", default: 443
    t.string "protocol", default: "https"
    t.string "username"
    t.string "password"
    t.boolean "ssl_verify", default: true
    t.string "device_name"
    t.string "device_id"
    t.string "model"
    t.string "serial_number"
    t.string "firmware_version"
    t.boolean "online", default: false
    t.datetime "last_checked_at"
    t.datetime "last_synced_at"
    t.boolean "listener_configured", default: false
    t.string "listener_url"
    t.datetime "listener_configured_at"
    t.integer "user_count", default: 0
    t.datetime "last_user_sync_at"
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ip", "port"], name: "index_terminals_on_ip_and_port", unique: true
    t.index ["listener_configured"], name: "index_terminals_on_listener_configured"
    t.index ["online"], name: "index_terminals_on_online"
    t.index ["provider"], name: "index_terminals_on_provider"
    t.index ["serial_number"], name: "index_terminals_on_serial_number", unique: true, where: "serial_number IS NOT NULL"
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
    t.index ["role_id", "user_id"], name: "index_users_roles_on_role_id_and_user_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", unique: true
  end

  add_foreign_key "clocks", "terminals"
  add_foreign_key "persons", "users"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "sessions", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
