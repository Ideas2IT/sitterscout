class Skill < ActiveRecord::Base
  belongs_to :sitter, :with_deleted => true
end
