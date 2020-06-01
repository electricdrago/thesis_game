class CreateJsspActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :jssp_activities do |t|
      t.integer :number_job
      t.integer :idJSSP
      t.integer :order
      t.integer :time_cost

      t.timestamps
    end
  end
end
