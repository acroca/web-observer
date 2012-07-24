class AddLastErrorToPetitions < ActiveRecord::Migration
  def change
    add_column :petitions, :last_error, :text
  end
end
