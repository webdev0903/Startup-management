class AddAttachmentPhotoToStartups < ActiveRecord::Migration
  def self.up
    change_table :startups do |t|
      t.attachment :photo
    end
  end

  def self.down
    drop_attached_file :startups, :photo
  end
end
