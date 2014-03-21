class CreateMailings < ActiveRecord::Migration
  def self.up
    create_table :mailings do |t|
      t.column :from, :string
      t.column :to, :text
      t.column :subject, :string
      t.column :body, :text
    end
  end

  def self.down
    drop_table :mailings
  end
end
