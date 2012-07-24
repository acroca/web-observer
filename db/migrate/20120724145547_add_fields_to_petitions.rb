class AddFieldsToPetitions < ActiveRecord::Migration
  def change
    add_column :petitions, :last_value, :string
    add_column :petitions, :last_check, :datetime
  end
end
