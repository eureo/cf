class CreateReactions < ActiveRecord::Migration
  def self.up
    create_table :reactions do |t|
      #t.column :email, :string
      #t.column :subject, :string
      #t.column :content, :text
    end
  end

  def self.down
    drop_table :reactions
  end
end
