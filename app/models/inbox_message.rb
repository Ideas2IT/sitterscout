class InboxMessage < Message
  belongs_to :messageable, :polymorphic => true
  
end
