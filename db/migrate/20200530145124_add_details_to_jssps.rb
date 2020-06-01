class AddDetailsToJssps < ActiveRecord::Migration[5.2]
  def change
    add_column :jssps, :level, :integer, :default => 0
    add_column :jssps, :number, :integer, :default => 0
  end
end
