class CreateScenes < ActiveRecord::Migration[5.2]
  def change
    create_table :scenes do |t|
      t.integer :storyId
      t.string :background
      t.integer :frame

      t.timestamps
    end
  end
end
