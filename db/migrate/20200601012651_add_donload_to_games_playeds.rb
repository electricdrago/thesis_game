class AddDonloadToGamesPlayeds < ActiveRecord::Migration[5.2]
  def change
    add_column :games_playeds, :downloaded, :integer, :default => 0
  end
end
