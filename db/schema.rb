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

ActiveRecord::Schema[8.1].define(version: 2026_04_23_114407) do
  create_table "inventory_counts", force: :cascade do |t|
    t.integer "actual_quantity", null: false
    t.date "counted_on", null: false
    t.datetime "created_at", null: false
    t.integer "member_id", null: false
    t.string "note"
    t.integer "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_inventory_counts_on_member_id"
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
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_members_on_email", unique: true
    t.index ["reset_password_token"], name: "index_members_on_reset_password_token", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "price_cents", null: false
    t.datetime "updated_at", null: false
  end

  create_table "purchases", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "member_id", null: false
    t.string "note"
    t.integer "price_per_unit_cents", null: false
    t.integer "product_id", null: false
    t.date "purchased_on", null: false
    t.integer "quantity", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_purchases_on_member_id"
    t.index ["product_id"], name: "index_purchases_on_product_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.integer "kind", null: false
    t.integer "member_id", null: false
    t.string "note"
    t.integer "product_id", null: false
    t.integer "quantity", default: 1
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_transactions_on_member_id"
    t.index ["product_id"], name: "index_transactions_on_product_id"
  end

  add_foreign_key "inventory_counts", "members"
  add_foreign_key "inventory_counts", "products"
  add_foreign_key "purchases", "members"
  add_foreign_key "purchases", "products"
  add_foreign_key "transactions", "members"
  add_foreign_key "transactions", "products"
end
