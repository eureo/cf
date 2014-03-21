class AddAuthenticatedTable < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true, :options => 'DEFAULT CHARSET=UTF8' do |t|
      t.column :login,            :string, :limit => 40
      t.column :email,            :string, :limit => 100
      t.column :crypted_password, :string, :limit => 40
      t.column :salt,             :string, :limit => 40
      t.column :created_at,       :datetime
      t.column :updated_at,       :datetime
      t.column :activation_code, :string, :limit => 40
      t.column :activated_at, :datetime
      t.column :password_reset_code, :string, :limit => 40
      t.column :remember_token, :string, :limit => 40
    end
    
		create_table "roles", :force => true, :options => 'DEFAULT CHARSET=UTF8' do |t|
			t.column "title", :string
		end
		
		create_table "roles_users", :id => false, :force => true, :options => 'DEFAULT CHARSET=UTF8' do |t|
			t. column "role_id", :integer
			t.column "user_id", :integer
		end
				
  end

  def self.down
    drop_table "users"
    drop_table "roles"
    drop_table "roles_users"
  end
end
