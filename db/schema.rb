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

ActiveRecord::Schema.define(version: 2020_09_06_210118) do

  create_table "dialogs", force: :cascade do |t|
    t.integer "storyId"
    t.integer "order"
    t.string "dialog"
    t.string "character"
    t.string "side"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "games_playeds", force: :cascade do |t|
    t.integer "idUser"
    t.integer "idJSSP"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "end_points"
    t.boolean "finished", default: false
    t.integer "downloaded", default: 0
  end

  create_table "jssp_activities", force: :cascade do |t|
    t.integer "number_job"
    t.integer "idJSSP"
    t.integer "order"
    t.integer "time_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "machine_type"
  end

  create_table "jssps", force: :cascade do |t|
    t.integer "number_machines"
    t.integer "time_limit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "diff_machines"
    t.string "machines"
    t.integer "level", default: 0
    t.integer "number", default: 0
    t.integer "answer"
  end

  create_table "scenes", force: :cascade do |t|
    t.integer "storyId"
    t.string "background"
    t.integer "frame"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "tutorial", default: false
  end

  create_table "steps", force: :cascade do |t|
    t.integer "idGame"
    t.integer "number_step"
    t.integer "idActivity"
    t.integer "number_machine"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stories", force: :cascade do |t|
    t.integer "strength", default: 0
    t.integer "intelligence", default: 0
    t.integer "curiosity", default: 0
    t.integer "organization", default: 0
    t.integer "construction", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "data"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "StrengthPoints", default: 0
    t.integer "IntelligencePoints", default: 0
    t.integer "CuriosityPoints", default: 0
    t.integer "OrganizationPoints", default: 0
    t.integer "ConstructionPoints", default: 0
    t.string "stories"
    t.float "points", default: 0.0
    t.integer "last_Game", default: -1
    t.integer "last_beginner", default: -1
    t.integer "last_intermidiate", default: -1
    t.integer "last_advanced", default: -1
    t.index ["name"], name: "index_users_on_name", unique: true
  end

end
