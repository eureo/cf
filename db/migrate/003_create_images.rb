class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images, :options => 'DEFAULT CHARSET=UTF8' do |t|
      t.column :article_id, :integer
      t.column :name, :string
    end
  end

  def self.down
    drop_table :images
  end
end
