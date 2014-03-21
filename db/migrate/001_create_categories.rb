class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories, :force => true, :options => 'DEFAULT CHARSET=UTF8' do |t|
      t.column :name, :string
			t.column :parent_id, :integer
			t.column :position, :integer
			t.column :permalink, :string
		end
    db_name = ActiveRecord::Base::connection.current_database()
    execute = "ALTER DATABASE #{db_name} CHARACTER SET utf8 COLLATE utf8_general_ci"
  end

  def self.down
    drop_table :categories
  end
end
