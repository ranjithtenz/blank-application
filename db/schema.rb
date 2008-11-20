# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081117061403) do

  create_table "acts_as_xapian_jobs", :force => true do |t|
    t.string  "model",    :null => false
    t.integer "model_id", :null => false
    t.string  "action",   :null => false
  end

  add_index "acts_as_xapian_jobs", ["model", "model_id"], :name => "index_acts_as_xapian_jobs_on_model_and_model_id", :unique => true

  create_table "artic_files", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.string   "file_path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tags"
  end

  create_table "article_files", :force => true do |t|
    t.integer  "article_id"
    t.string   "file_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "articles", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tags"
  end

  create_table "audios", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.string   "file_path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tags"
  end

  create_table "colors", :force => true do |t|
    t.integer  "element_id"
    t.string   "bgcolor"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.text     "text"
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "elements", :force => true do |t|
    t.string   "name"
    t.string   "bgcolor"
    t.string   "template"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feed_items", :force => true do |t|
    t.string   "guid"
    t.integer  "feed_source_id"
    t.string   "title"
    t.text     "description"
    t.string   "author"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feed_sources", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.string   "url",         :limit => 1024
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "generic_items", :force => true do |t|
    t.string   "item_type",          :limit => 11,                                        :default => "", :null => false
    t.integer  "user_id"
    t.text     "user_name",          :limit => 2147483647
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "number_of_comments", :limit => 8
    t.string   "workspace_names",    :limit => 341
    t.decimal  "average_rate",                             :precision => 14, :scale => 4
  end

  create_table "images", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.string   "file_path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tags"
  end

  create_table "items", :force => true do |t|
    t.string   "itemable_type"
    t.integer  "itemable_id"
    t.integer  "workspace_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pictures", :force => true do |t|
    t.string   "name"
    t.string   "picture_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public_items", :force => true do |t|
    t.integer  "itemable_id"
    t.string   "itemable_type"
    t.integer  "extranet_category_id"
    t.integer  "suggester_id"
    t.integer  "validated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "publications", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "imported"
    t.string   "title"
    t.string   "author"
    t.string   "link"
    t.text     "description"
    t.string   "file_path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tags"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "rating"
    t.integer  "user_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "addr",                      :limit => 500
    t.string   "laboratory"
    t.string   "phone"
    t.string   "mobile"
    t.string   "activity"
    t.text     "edito"
    t.string   "image_path",                :limit => 500
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "invitation_code",           :limit => 40
    t.string   "password_reset_code",       :limit => 40
    t.integer  "system_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

  create_table "users_workspaces", :force => true do |t|
    t.integer  "workspace_id"
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.string   "file_path"
    t.string   "encoded_file"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tags"
  end

  create_table "workspaces", :force => true do |t|
    t.integer  "creator_id"
    t.text     "description"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
