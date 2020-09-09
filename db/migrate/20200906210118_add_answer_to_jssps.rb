class AddAnswerToJssps < ActiveRecord::Migration[5.2]
  def change
    add_column :jssps, :answer, :integer
  end
end
