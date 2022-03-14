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

ActiveRecord::Schema.define(version: 20200907131437) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "next_day", default: false
    t.integer "approver"
    t.string "status", default: "なし"
    t.boolean "checked", default: false
    t.datetime "initial_started_at"
    t.datetime "initial_finished_at"
    t.datetime "changed_started_at"
    t.datetime "changed_finished_at"
    t.boolean "approved", default: false
    t.datetime "approved_at"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "offices", force: :cascade do |t|
    t.string "name"
    t.string "attendance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "office_id"
  end

  create_table "one_month_attendances", force: :cascade do |t|
    t.date "month"
    t.string "status", default: "なし"
    t.integer "approver"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "checked", default: false
    t.index ["user_id"], name: "index_one_month_attendances_on_user_id"
  end

  create_table "overtimes", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "will_finish"
    t.string "note"
    t.string "status", default: "なし"
    t.integer "approver"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "next_day", default: false
    t.boolean "checked", default: false
    t.index ["user_id"], name: "index_overtimes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.boolean "admin", default: false
    t.string "remember_digest"
    t.boolean "superior", default: false
    t.datetime "basic_work_time", default: "2022-03-13 23:00:00"
    t.datetime "designated_work_start_time", default: "2022-03-14 00:00:00"
    t.datetime "designated_work_end_time", default: "2022-03-14 09:00:00"
    t.string "affiliation"
    t.integer "employee_number"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
