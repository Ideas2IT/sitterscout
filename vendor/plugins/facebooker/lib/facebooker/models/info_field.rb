require 'facebooker/model'
require 'facebooker/models/info_item'

module Facebooker
  class InfoField
    include Model
    attr_accessor :field, :items
    
    populating_hash_settable_list_accessor :items, InfoItem
    
    def to_json
      { :field => field, :items => items }.to_json
    end
  end
end