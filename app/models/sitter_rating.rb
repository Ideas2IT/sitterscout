class SitterRating < ActiveRecord::Base

  belongs_to :sitter
  belongs_to :parent
  
end
