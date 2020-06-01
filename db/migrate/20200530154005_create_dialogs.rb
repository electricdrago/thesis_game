class CreateDialogs < ActiveRecord::Migration[5.2]
  def change
    create_table :dialogs do |t|
      t.integer :storyId
      t.integer :order
      t.string :dialog
      t.string :character
      t.string :side

      t.timestamps
    end
  end
end
