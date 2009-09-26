class AddHourlyRateToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :hourly_rate, :string
  end

  def self.down
    remove_column :profiles, :hourly_rate
  end
end
