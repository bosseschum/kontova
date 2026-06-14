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

ActiveRecord::Schema[8.1].define(version: 2026_06_14_155134) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
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
    t.datetime "created_at", null: false
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

  create_table "bank_accounts", force: :cascade do |t|
    t.bigint "bank_connection_id", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "EUR", null: false
    t.string "iban"
    t.string "product"
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_connection_id"], name: "index_bank_accounts_on_bank_connection_id"
    t.index ["uid"], name: "index_bank_accounts_on_uid", unique: true
  end

  create_table "bank_connections", force: :cascade do |t|
    t.string "authorization_id", null: false
    t.string "bank_name", null: false
    t.string "bic"
    t.datetime "consent_expires_at"
    t.datetime "created_at", null: false
    t.bigint "organization_id", null: false
    t.string "session_id"
    t.datetime "updated_at", null: false
    t.index ["authorization_id"], name: "index_bank_connections_on_authorization_id", unique: true
    t.index ["organization_id"], name: "index_bank_connections_on_organization_id"
    t.index ["session_id"], name: "index_bank_connections_on_session_id", unique: true, where: "(session_id IS NOT NULL)"
  end

  create_table "inventory_counts", force: :cascade do |t|
    t.integer "actual_quantity", null: false
    t.date "counted_on", null: false
    t.datetime "created_at", null: false
    t.integer "member_id", null: false
    t.string "note"
    t.integer "organization_id"
    t.integer "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_inventory_counts_on_member_id"
    t.index ["organization_id"], name: "index_inventory_counts_on_organization_id"
    t.index ["product_id"], name: "index_inventory_counts_on_product_id"
  end

  create_table "members", force: :cascade do |t|
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.string "display_name", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.boolean "super_admin"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_members_on_email", unique: true
    t.index ["reset_password_token"], name: "index_members_on_reset_password_token", unique: true
  end

  create_table "mixed_crate_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "mixed_crate_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity"
    t.datetime "updated_at", null: false
    t.index ["mixed_crate_id"], name: "index_mixed_crate_items_on_mixed_crate_id"
    t.index ["product_id"], name: "index_mixed_crate_items_on_product_id"
  end

  create_table "mixed_crates", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "price_cents"
    t.datetime "updated_at", null: false
  end

  create_table "organization_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "lives_on_site", default: false, null: false
    t.bigint "member_id", null: false
    t.bigint "organization_id", null: false
    t.boolean "pays_fee", default: true, null: false
    t.string "pin"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["member_id", "organization_id"], name: "idx_on_member_id_organization_id_f36c6f7100", unique: true
    t.index ["member_id"], name: "index_organization_memberships_on_member_id"
    t.index ["organization_id"], name: "index_organization_memberships_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "subdomain"
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "crate_price_cents"
    t.integer "crate_size"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "organization_id"
    t.integer "price_cents", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_products_on_organization_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "member_id", null: false
    t.string "note"
    t.integer "organization_id"
    t.integer "price_per_unit_cents"
    t.integer "product_id", null: false
    t.date "purchased_on", null: false
    t.integer "quantity", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_purchases_on_member_id"
    t.index ["organization_id"], name: "index_purchases_on_organization_id"
    t.index ["product_id"], name: "index_purchases_on_product_id"
  end

  create_table "requests", force: :cascade do |t|
    t.integer "amount_cents"
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.integer "kind", default: 0, null: false
    t.integer "member_id", null: false
    t.text "note"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_requests_on_member_id"
  end

  create_table "settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key"
    t.integer "organization_id"
    t.datetime "updated_at", null: false
    t.string "value"
    t.index ["organization_id"], name: "index_settings_on_organization_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.integer "kind", null: false
    t.integer "member_id", null: false
    t.string "note"
    t.integer "organization_id"
    t.integer "original_amount_cents"
    t.integer "product_id"
    t.integer "quantity", default: 1
    t.boolean "sponsored"
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_transactions_on_member_id"
    t.index ["organization_id"], name: "index_transactions_on_organization_id"
    t.index ["product_id"], name: "index_transactions_on_product_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bank_accounts", "bank_connections"
  add_foreign_key "bank_connections", "organizations"
  add_foreign_key "inventory_counts", "members"
  add_foreign_key "inventory_counts", "organizations"
  add_foreign_key "inventory_counts", "products"
  add_foreign_key "mixed_crate_items", "mixed_crates"
  add_foreign_key "mixed_crate_items", "products"
  add_foreign_key "organization_memberships", "members"
  add_foreign_key "organization_memberships", "organizations"
  add_foreign_key "products", "organizations"
  add_foreign_key "purchases", "members"
  add_foreign_key "purchases", "organizations"
  add_foreign_key "purchases", "products"
  add_foreign_key "requests", "members"
  add_foreign_key "settings", "organizations"
  add_foreign_key "transactions", "members"
  add_foreign_key "transactions", "organizations"
  add_foreign_key "transactions", "products"
end
