class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments, :options => 'DEFAULT CHARSET=UTF8' do |t|
      t.column :article_id, :integer
      t.column :file, :string
    end
  end

  def self.down
    drop_table :attachments
  end
end
