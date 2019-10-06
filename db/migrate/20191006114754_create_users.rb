class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: :uuid do |t|
      t.string :api_key, null: false
      t.timestamps
    end

    add_index :users, :api_key
  end
end
