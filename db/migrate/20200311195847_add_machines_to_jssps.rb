class AddMachinesToJssps < ActiveRecord::Migration[5.2]
  def change
    add_column :jssps, :machines, :string
  end
end
