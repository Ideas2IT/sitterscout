class State < ActiveRecord::Base
  has_many :metro_areas
  has_many :profiles
end
