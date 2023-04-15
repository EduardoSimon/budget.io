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

ActiveRecord::Schema[7.0].define(version: 2023_04_15_120018) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "auth_session_status", ["success", "failed", "in_progress"]

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.string "iban"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "institution_id"
    t.string "external_account_id"
    t.bigint "budget_id"
    t.decimal "balance", precision: 8, scale: 2
    t.index ["budget_id"], name: "index_accounts_on_budget_id"
    t.index ["institution_id"], name: "index_accounts_on_institution_id"
  end

  create_table "auth_sessions", force: :cascade do |t|
    t.uuid "external_id"
    t.jsonb "raw_response"
    t.enum "status", default: "in_progress", null: false, enum_type: "auth_session_status"
    t.bigint "account_id"
    t.string "redirect_url"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_account_id"
    t.string "external_institution_id"
    t.index ["account_id"], name: "index_auth_sessions_on_account_id"
  end

  create_table "budgets", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ready_to_assign_cents", default: 0, null: false
    t.string "ready_to_assign_currency", default: "EUR", null: false
    t.integer "ready_to_assign_category_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "budget_id"
    t.integer "assigned_amount_cents", default: 0, null: false
    t.string "assigned_amount_currency", default: "EUR", null: false
    t.integer "target_amount_cents", default: 0, null: false
    t.string "target_amount_currency", default: "EUR", null: false
    t.index ["budget_id"], name: "index_categories_on_budget_id"
  end

  create_table "institutions", force: :cascade do |t|
    t.string "name"
    t.string "institution_id"
    t.string "thumbnail_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["institution_id"], name: "unique_institution_id", unique: true
  end

  create_table "movements", force: :cascade do |t|
    t.boolean "reconciled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payer", null: false
    t.bigint "category_id"
    t.string "external_id"
    t.string "description"
    t.bigint "account_id"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "EUR", null: false
    t.index ["account_id"], name: "index_movements_on_account_id"
    t.index ["category_id"], name: "index_movements_on_category_id"
    t.index ["external_id"], name: "index_movements_on_external_id"
  end

  add_foreign_key "accounts", "budgets"
  add_foreign_key "accounts", "institutions"
  add_foreign_key "auth_sessions", "accounts"
  add_foreign_key "categories", "budgets"
  add_foreign_key "movements", "accounts"
  add_foreign_key "movements", "categories"
end
