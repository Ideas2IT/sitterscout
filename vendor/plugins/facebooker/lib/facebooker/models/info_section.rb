require 'facebooker/model'
require 'facebooker/models/info_field'

module Facebooker
  class InfoSection
    include Model
    attr_accessor :title, :info_fields, :type
    
    populating_hash_settable_list_accessor :info_fields, InfoField
    
    def to_json
      { :title => title, :info_fields => info_fields, :type => type }.to_json
    end
  end
end