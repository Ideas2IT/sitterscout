class SentMessage < Message
  belongs_to :messageable, :polymorphic => true
  
end
