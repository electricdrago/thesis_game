class AddTutorialToScenes < ActiveRecord::Migration[5.2]
  def change
    add_column :scenes, :tutorial, :boolean, :default => false
  end
end
