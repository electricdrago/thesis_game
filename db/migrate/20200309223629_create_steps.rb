class CreateSteps < ActiveRecord::Migration[5.2]
  def change
    create_table :steps do |t|
      t.integer :idGame
      t.integer :number_step
      t.integer :idActivity
      t.integer :number_machine
      t.integer :position

      t.timestamps
    end
  end
end
