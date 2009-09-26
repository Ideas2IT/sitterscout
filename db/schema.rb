# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 41) do

  create_table "cell_carriers", :force => true do |t|
    t.string   "name"
    t.string   "email_suffix"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "children", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "age"
  end

  create_table "comatose_pages", :force => true do |t|
    t.integer  "parent_id"
    t.text     "full_path"
    t.string   "title"
    t.string   "slug"
    t.string   "keywords"
    t.text     "body"
    t.string   "filter_type", :limit => 25, :default => "Textile"
    t.string   "author"
    t.integer  "position",                  :default => 0
    t.integer  "version"
    t.datetime "updated_on"
    t.datetime "created_on"
  end

  create_table "confirmed_sitters", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "sitter_id"
    t.string   "aasm_state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "consenting_parents", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "underaged_sitter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approved",              :default => false
    t.boolean  "notify_child_added"
    t.boolean  "notify_parent_request"
  end

  create_table "countries", :force => true do |t|
    t.string "name"
  end

  create_table "friends", :force => true do |t|
    t.integer  "parent_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendship_statuses", :force => true do |t|
    t.string "name"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "friend_id"
    t.integer  "user_id"
    t.boolean  "initiator",            :default => false
    t.datetime "created_at"
    t.integer  "friendship_status_id"
    t.string   "status"
    t.datetime "accepted_at"
    t.boolean  "hide_connection",      :default => false
  end

  add_index "friendships", ["user_id"], :name => "index_friendships_on_user_id"
  add_index "friendships", ["friendship_status_id"], :name => "index_friendships_on_friendship_status_id"

  create_table "invitations", :force => true do |t|
    t.string   "email_addresses"
    t.string   "message"
    t.string   "user_id"
    t.datetime "created_at"
  end

  create_table "jobs", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "sitter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.datetime "date_from"
    t.datetime "date_to"
    t.boolean  "active"
    t.string   "status"
    t.string   "type"
    t.boolean  "notification_sent"
  end

  add_index "jobs", ["parent_id"], :name => "index_jobs_on_parent_id"
  add_index "jobs", ["sitter_id"], :name => "index_jobs_on_sitter_id"

  create_table "messages", :force => true do |t|
    t.integer  "user_id"
    t.integer  "recipient_id"
    t.string   "subject"
    t.datetime "created_at"
    t.text     "body"
    t.string   "status",            :default => "new"
    t.boolean  "sender_deleted",    :default => false
    t.boolean  "recipient_deleted", :default => false
    t.datetime "deleted_at"
    t.integer  "messageable_id"
    t.string   "messageable_type"
  end

  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"
  add_index "messages", ["recipient_id"], :name => "index_messages_on_recipient_id"
  add_index "messages", ["created_at"], :name => "index_messages_on_created_at"
  add_index "messages", ["status"], :name => "index_messages_on_status"
  add_index "messages", ["recipient_deleted"], :name => "index_messages_on_recipient_deleted"

  create_table "metro_areas", :force => true do |t|
    t.string  "name"
    t.integer "state_id"
    t.integer "country_id"
    t.integer "users_count", :default => 0
  end

  create_table "page_versions", :force => true do |t|
    t.integer  "page_id"
    t.integer  "version"
    t.integer  "parent_id"
    t.text     "full_path"
    t.string   "title"
    t.string   "slug"
    t.string   "keywords"
    t.text     "body"
    t.string   "filter_type", :limit => 25, :default => "Textile"
    t.string   "author"
    t.integer  "position",                  :default => 0
    t.datetime "updated_on"
    t.datetime "created_on"
  end

  create_table "parents_sitters", :id => false, :force => true do |t|
    t.integer "parent_id"
    t.integer "sitter_id"
  end

  create_table "photos", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "width"
    t.integer  "height"
  end

  add_index "photos", ["parent_id"], :name => "index_photos_on_parent_id"
  add_index "photos", ["user_id"], :name => "index_photos_on_user_id"

  create_table "profiles", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "dob"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "zipcode"
    t.integer  "sitter_id"
    t.integer  "parent_id"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.integer  "state_id"
    t.float    "lat"
    t.float    "lng"
    t.string   "address"
    t.boolean  "text_message"
    t.boolean  "email",               :default => true
    t.string   "datetime_phone"
    t.string   "evening_phone"
    t.string   "cell_phone"
    t.boolean  "not_searchable",      :default => true
    t.integer  "cell_carrier_id"
    t.string   "mondays"
    t.string   "tuesdays"
    t.string   "wednesdays"
    t.string   "thursdays"
    t.string   "fridays"
    t.string   "saturdays"
    t.string   "sundays"
    t.integer  "num_children"
    t.string   "full_name"
    t.boolean  "visible_to_everyone", :default => true
    t.string   "hourly_rate"
  end

  add_index "profiles", ["sitter_id"], :name => "index_profiles_on_sitter_id"
  add_index "profiles", ["parent_id"], :name => "index_profiles_on_parent_id"

  create_table "removed_peoples", :force => true do |t|
    t.integer  "user_id"
    t.integer  "removed_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "request_sitters", :force => true do |t|
    t.integer "request_id"
    t.integer "sitter_id"
    t.string  "state"
  end

  add_index "request_sitters", ["request_id"], :name => "index_request_sitters_on_request_id"
  add_index "request_sitters", ["sitter_id"], :name => "index_request_sitters_on_sitter_id"

  create_table "requests", :force => true do |t|
    t.integer  "job_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "sessions", :force => true do |t|
    t.string   "sessid"
    t.text     "data"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "sessions", ["sessid"], :name => "index_sessions_on_sessid"

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skills", :force => true do |t|
    t.boolean  "babies"
    t.boolean  "toddlers"
    t.boolean  "preschoolers"
    t.boolean  "schoolaged"
    t.boolean  "cook"
    t.boolean  "homework"
    t.boolean  "bathe"
    t.boolean  "kidstobed"
    t.boolean  "entertain"
    t.integer  "max_mileage"
    t.integer  "sitter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "transportation"
    t.boolean  "specialneeds"
    t.boolean  "multiples"
  end

  create_table "states", :force => true do |t|
    t.string "name"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.text     "description"
    t.integer  "avatar_id"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.text     "stylesheet"
    t.integer  "view_count",                              :default => 0
    t.boolean  "vendor",                                  :default => false
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.integer  "state_id"
    t.integer  "metro_area_id"
    t.string   "login_slug"
    t.boolean  "notify_friend_requests",                  :default => true
    t.boolean  "notify_community_news",                   :default => true
    t.integer  "country_id"
    t.datetime "last_login_at"
    t.string   "zip"
    t.date     "birthday"
    t.string   "gender"
    t.boolean  "profile_public",                          :default => true
    t.integer  "role_id"
    t.string   "type"
    t.string   "account_type"
    t.string   "aasm_state"
    t.boolean  "terms_of_use"
    t.boolean  "minor",                                   :default => false
    t.integer  "consenting_parent_id"
    t.datetime "deleted_at"
    t.boolean  "suspended",                               :default => false
  end

  add_index "users", ["avatar_id"], :name => "index_users_on_avatar_id"
  add_index "users", ["activated_at"], :name => "index_users_on_activated_at"
  add_index "users", ["vendor"], :name => "index_users_on_vendor"
  add_index "users", ["login_slug"], :name => "index_users_on_login_slug"

  create_table "votes", :force => true do |t|
    t.string   "user_id"
    t.integer  "poll_id"
    t.integer  "choice_id"
    t.datetime "created_at"
  end

  create_table "zip_codes", :force => true do |t|
    t.string   "country_code"
    t.string   "postal_code"
    t.string   "latitude"
    t.string   "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
