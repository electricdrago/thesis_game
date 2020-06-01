class CreateStories < ActiveRecord::Migration[5.2]
  def change
    create_table :stories do |t|
      t.integer :strength, :default => 0
      t.integer :intelligence, :default => 0
      t.integer :curiosity, :default => 0
      t.integer :organization, :default => 0
      t.integer :construction, :default => 0

      t.timestamps
    end
  end
end
