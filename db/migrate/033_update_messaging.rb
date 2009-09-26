class UpdateMessaging < ActiveRecord::Migration
  def self.up
    drop_table :messages
    
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
     
    end

    add_index "messages", ["user_id"], :name => "index_messages_on_user_id"
    add_index "messages", ["recipient_id"], :name => "index_messages_on_recipient_id"
    add_index "messages", ["created_at"], :name => "index_messages_on_created_at"
    add_index "messages", ["status"], :name => "index_messages_on_status"
    add_index "messages", ["recipient_deleted"], :name => "index_messages_on_recipient_deleted"
     add_column :messages, :messageable_id, :integer
      add_column :messages, :messageable_type, :string
  end

  def self.down
  end
end
