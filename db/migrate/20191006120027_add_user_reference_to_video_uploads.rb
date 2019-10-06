class AddUserReferenceToVideoUploads < ActiveRecord::Migration[5.2]
  def change
    add_reference :video_uploads, :user, type: :uuid, foreign_key: true, index: true
  end
end
