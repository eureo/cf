desc 'cms init'
task :cms_init => [
	:create_root_category,
  :create_roles,
 	:create_admin_user,
  :activate_all_users
]

desc "add email and email_admin roles"
task :add_email_role => :environment do
  Role.find_or_create_by_title("email_admin")
  Role.find_or_create_by_title("email")
end

desc 'create the default root category'
task :create_root_category => :environment do
	if Category.find_by_name("Root") == nil
		root = Category.create(:name => "Root")
		puts "Creating root category for CMS"
		raise "problem while saving root category" if !root.save
	end
end

desc 'Create the default roles'
task :create_roles => :environment do
	# Create the USER role
  if Role.find_by_title("user") == nil
    puts "Creating user role"
    role = Role.new(:title => "user")
    raise "Couldn't save user role!" if !role.save
  end

  # Create the ADMIN role
  if Role.find_by_title("admin") == nil
    puts "Creating admin role"
    role = Role.new(:title => "admin")
    raise "Couldn't save admin role!" if !role.save
  end

	# Create the CMS role
  if Role.find_by_title("cms") == nil
    puts "Creating cms role"
    role = Role.new(:title => "cms")
    raise "Couldn't save cms role!" if !role.save
  end

	# Create the CMS_ADMIN role
  if Role.find_by_title("cms_admin") == nil
    puts "Creating cms admin role"
    role = Role.new(:title => "cms_admin")
    raise "Couldn't save cms admin role!" if !role.save
  end


end

desc 'Create the administrator super-user'
task :create_admin_user => :environment do
  # Create the administrator user, if needed
  if User.find_by_login("admin") == nil
    puts "Creating admin user"
    u = User.new(:login => "admin", :email => "admin@localhost", :password => "testing", :password_confirmation => "testing")
    raise "Couldn't save administrator!" if !u.save
  end

	# assigning admin and user roles to admin user
  u = User.find_by_login("admin")
  if !u.roles.include?(Role.find_by_title("admin"))
    u.roles << Role.find_by_title("admin")
  end
  if !u.roles.include?(Role.find_by_title("user"))
    u.roles << Role.find_by_title("user")
  end
  if !u.roles.include?(Role.find_by_title("cms"))
    u.roles << Role.find_by_title("cms")
  end
  if !u.roles.include?(Role.find_by_title("cms_admin"))
    u.roles << Role.find_by_title("cms_admin")
  end

  raise "Couldn't save administrator after assigning roles!" if !u.save
end

desc 'Activate all users'
task :activate_all_users => :environment do
  User.update_all ['activated_at = ?', Time.now]
end

