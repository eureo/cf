class CreateCsvFiles < ActiveRecord::Migration
  def self.up
    create_table :csv_files, :options => 'DEFAULT CHARSET=UTF8' do |t|
      t.column "content_type", :string
      t.column "filename", :string     
      t.column "size", :integer
      t.column "format", :string
    end

  end

  def self.down
    drop_table :csv_files
  end
end
