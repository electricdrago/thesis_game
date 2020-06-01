class CreateJssps < ActiveRecord::Migration[5.2]
  def change
    create_table :jssps do |t|
      t.integer :number_machines
      t.integer :time_limit

      t.timestamps
    end
  end
end
