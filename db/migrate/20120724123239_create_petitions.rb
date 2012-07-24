class CreatePetitions < ActiveRecord::Migration
  def change
    create_table :petitions do |t|
      t.string :request_url
      t.string :css_selector
      t.string :callback_url

      t.timestamps
    end
  end
end
