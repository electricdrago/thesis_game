class AddDetailsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :IntelligencePoints, :integer, :default => 0
    add_column :users, :CuriosityPoints, :integer, :default => 0
    add_column :users, :OrganizationPoints, :integer, :default => 0
    add_column :users, :ConstructionPoints, :integer, :default => 0
    add_column :users, :stories, :string
    add_column :users, :points, :float, :default => 0
    add_column :users, :last_Game, :integer, :default => -1
    add_column :users, :last_beginner, :integer, :default => -1
    add_column :users, :last_intermidiate, :integer, :default => -1
    add_column :users, :last_advanced, :integer, :default => -1
  end
end
