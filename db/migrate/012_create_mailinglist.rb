class CreateMailinglist < ActiveRecord::Migration
  def self.up
    create_table :mailinglists, :options => 'DEFAULT CHARSET=UTF8' do |t|
      t.column "name", :string
    end
    
    create_table :ml_members, :options => 'DEFAULT CHARSET=UTF8' do |t|
      t.column "email", :string
    end
    
    create_table :mailinglists_ml_members, :id => false do |t|
      t.column :mailinglist_id, :integer
      t.column :ml_member_id, :integer
    end

  end

  def self.down
    drop_table :mailinglists
    drop_table :ml_members
    drop_table :mailinglists_ml_members
  end
end