class CreateNewsletterMemberSectors < ActiveRecord::Migration
  def self.up
    create_table :newsletter_member_sectors, :options => 'DEFAULT CHARSET=UTF8' do |t|
      t.column :newsletter_member_id, :integer
      t.column :sector_id, :integer
    end
  end

  def self.down
    drop_table :newsletter_member_sectors
  end
end
