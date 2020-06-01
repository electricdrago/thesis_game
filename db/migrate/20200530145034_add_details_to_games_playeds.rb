class AddDetailsToGamesPlayeds < ActiveRecord::Migration[5.2]
  def change
    add_column :games_playeds, :end_points, :float
    add_column :games_playeds, :finished, :boolean, :default => false
  end
end
