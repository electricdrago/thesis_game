class AddMachinetypeToJsspActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :jssp_activities, :machine_type, :integer
  end
end
