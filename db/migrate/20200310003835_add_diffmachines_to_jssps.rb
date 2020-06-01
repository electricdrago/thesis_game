class AddDiffmachinesToJssps < ActiveRecord::Migration[5.2]
  def change
    add_column :jssps, :diff_machines, :boolean
  end
end
