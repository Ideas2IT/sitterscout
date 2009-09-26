class CreateDb < ActiveRecord::Migration
  def self.up
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
    end

    create_table "metro_areas", :force => true do |t|
      t.string  "name"
      t.integer "state_id"
      t.integer "country_id"
      t.integer "users_count", :default => 0
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



    create_table "profiles", :force => true do |t|
      t.string   "first_name"
      t.string   "last_name"
      t.datetime "dob"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "zipcode"
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
      t.boolean  "email"
      t.string  "datetime_phone"
      t.string  "evening_phone"
      t.string  "cell_phone"
      t.boolean "not_searchable", :default => 1
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

    create_table "states", :force => true do |t|
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

  def self.down
    drop_table :friends
  end
end
