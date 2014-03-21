class CreateNewsletterMembers < ActiveRecord::Migration
  def self.up
    create_table :newsletter_members, :options => 'DEFAULT CHARSET=UTF8' do |t|
      t.column :email, :string
    end
  end

  def self.down
    drop_table :newsletter_members
  end
end
