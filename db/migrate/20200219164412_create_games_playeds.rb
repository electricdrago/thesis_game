class CreateGamesPlayeds < ActiveRecord::Migration[5.2]
  def change
    create_table :games_playeds do |t|
      t.integer :idUser
      t.integer :idJSSP

      t.timestamps
    end
  end
end
