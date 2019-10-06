class CreateVideoUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :video_uploads, id: :uuid do |t|
      t.integer :from_seconds, null: false
      t.integer :to_seconds, null: false
      t.integer :to_seconds, null: false
      t.integer :processing_status, null: false, default: 0
      t.string :message
      t.timestamps
    end

    add_index :video_uploads, :processing_status
  end
end
