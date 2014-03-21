# =============================================================================
# VARIABLES
# =============================================================================

set :svn_user, "franck"
set :user, "deploy"
set :application, "cf2010"
set :repository, "http://svn.barouf.info/cf2010/trunk"
set :server, "de-fra.com"
set :root, "/var/www/#{application}/current"
set :keep_releases, 3
set :use_sudo, true
set :sudo, "sudo -p Password:"
set :rails_version, 1-1-6

set :svn_username, "franck" 
set :svn_password, "thibamay"

set :deploy_to, "/var/www/#{application}" 

set :dbname, "cf"
set :dbhost, "localhost"
set :dbuser, "root"
set :dbpass, ""

ssh_options[:port] = 32100


# =============================================================================
# ROLES
# =============================================================================

role :web, server
role :app, server
role :db, server , :primary => true


# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================

# =============================================================================
# STANDARD TASKS REMANIED
# =============================================================================

desc "show standard variables"
task :show_variables, :roles => :web do
  puts "Shared Path: #{shared_path}"
  puts "Current Path: #{current_path}"
end

desc "Set up the expected application directory structure on all boxes"
task :setup, :roles => [:app, :db, :web] do
	# adding folders for file_column and ferret
  run <<-CMD
    mkdir -p -m 775 #{releases_path} #{shared_path}/system #{shared_path}/files #{shared_path}/index #{shared_path}/csv_file #{shared_path}/cache #{shared_path}/tmp &&
    mkdir -p -m 777 #{shared_path}/log
  CMD
end


desc <<-DESC
Update all servers with the latest release of the source code. All this does
is do a checkout (as defined by the selected scm module).
DESC
task :update_code, :roles => [:app, :db, :web] do
  on_rollback { delete release_path, :recursive => true }

  source.checkout(self)

	# adding symlinks for file_column and ferret
  run <<-CMD
    rm -rf #{release_path}/log #{release_path}/public/system #{release_path}/index #{release_path}/public/files &&
    ln -nfs #{shared_path}/log #{release_path}/log &&
    ln -nfs #{shared_path}/system #{release_path}/public/system &&
    ln -nfs #{shared_path}/files #{release_path}/public/files &&
    ln -nfs #{shared_path}/cache #{release_path}/public/cache &&
    ln -nfs #{shared_path}/index #{release_path}/index &&
    ln -nfs #{shared_path}/csv_file #{release_path}/csv_file &&
    ln -nfs #{shared_path}/tmp #{release_path}/tmp &&
    ln -nfs #{shared_path}/sitemap.xml #{release_path}/public/sitemap.xml
  CMD
end

# =============================================================================
# TASKS
# =============================================================================

desc "dreamhost deploy and migration task"
task :deploy_and_migrate_on_dreamhost, :roles => :web do
	transaction do
		update_code
		disable_web
		symlink
		symlink_rails
		symlink_plugins
		puts "Changing permissions ..."
		run "chmod 755 #{root}/public/dispatch.fcgi"
		run "chmod 755 #{root}/public/.htaccess"
		puts "Database settings ..."
		run "mv #{root}/config/database.example.yml #{root}/config/database.yml"
    backup
    set :migrate_env, "VERSION=0"
    migrate
    set :migrate_env, ""
    migrate
	end
		puts "Restarting server ..."
		run "killall -USR1 dispatch.fcgi"
		run "touch #{root}/public/dispatch.fcgi"
end

desc "dreamhost deploy task"
task :deploy_on_dreamhost, :roles => :web do
	transaction do
		update_code
		disable_web
		symlink
		symlink_rails
		symlink_plugins
		puts "Changing permissions ..."
		run "chmod 755 #{root}/public/dispatch.fcgi"
		run "chmod 755 #{root}/public/.htaccess"
		puts "Database settings ..."
		run "mv #{root}/config/database.example.yml #{root}/config/database.yml"
	end
		puts "Restarting server ..."
		run "killall -USR1 dispatch.fcgi"
		run "touch #{root}/public/dispatch.fcgi"
		enable_web
end

desc "perform database backup"
task :backup, :roles => :db, :only => { :primary => true } do
  # the on_rollback handler is only executed if this task is executed within
  # a transaction (see below), AND it or a subsequent task fails.
  on_rollback { delete "#{shared_path}/dump.sql" }
	
	delete "#{shared_path}/dump.sql"
  run "mysqldump -u #{dbuser} -p #{dbname} -h #{dbhost} -t > #{shared_path}/dump.sql" do |ch, stream, out|
    ch.send_data "#{dbpass}\n" if out =~ /^Enter password:/
  end
  `rsync --rsh="ssh -p #{ssh_options[:port]}" #{user}@#{roles[:db][0].host}:#{shared_path}/dump.sql #{File.dirname(__FILE__)}/../backups/`
end

desc "import database backup"
task :use_backup, :roles => :db, :only => { :primary => true } do
	run "mysql -u #{dbuser} -p #{dbname} -h #{dbhost} < #{shared_path}/dump.sql" do |ch, stream, out|
    ch.send_data "#{dbpass}\n" if out =~ /^Enter password:/
	end
end

task :symlink_rails, :roles => :web do
	puts "Symlinking rails #{rails_version}"
	run "ln -nfs /home/#{user}/rails/rails_#{rails_version} #{release_path}/vendor/rails"
end

#################################################
# PLUGINS
#################################################

task :symlink_plugins, :roles => :web do
	puts "Installing plugins:"
	run "mkdir #{release_path}/vendor/plugins"
	file_column
	google_analytics
	#exception_notification
	acts_as_authenticated
	acl_system
	acts_as_taggable
  ez_where
  error_messages_for
  unicode_hacks
  acts_as_attachment
  validates_as_email
  campaign_monitor
end

task :campaign_monitor, :roles => :web do
	puts "campaign_monitor ..."
	run "ln -nfs /home/#{user}/rails/plugins/campaign_monitor #{release_path}/vendor/plugins/validates_as_email"
end

task :validates_as_email, :roles => :web do
	puts "validates_as_email ..."
	run "ln -nfs /home/#{user}/rails/plugins/validates_as_email #{release_path}/vendor/plugins/validates_as_email"
end

task :file_column, :roles => :web do
	puts "filecolumn ..."
	run "ln -nfs /home/#{user}/rails/plugins/file_column #{release_path}/vendor/plugins/file_column"
end

task :google_analytics, :roles => :web do
	puts "google analytics ..."
	run "ln -nfs /home/#{user}/rails/plugins/google_analytics #{release_path}/vendor/plugins/google_analytics"
end

task :exception_notification, :roles => :web do
	puts "exception notification ..."
	run "ln -nfs /home/#{user}/rails/plugins/exception_notification #{release_path}/vendor/plugins/exception_notification"
end

task :acts_as_authenticated, :roles => :web do
	puts "acts as authenticated ..."
	run "ln -nfs /home/#{user}/rails/plugins/acts_as_authenticated #{release_path}/vendor/plugins/acts_as_authenticated"
end

task :acl_system, :roles => :web do
	puts "acl system ..."
	run "ln -nfs /home/#{user}/rails/plugins/acl_system #{release_path}/vendor/plugins/acl_system"
end

task :acts_as_taggable, :roles => :web do
	puts "acts as taggable ..."
	run "ln -nfs /home/#{user}/rails/plugins/acts_as_taggable #{release_path}/vendor/plugins/acts_as_taggable"
end

task :ez_where, :roles => :web do
	puts "ez_where ..."
	run "ln -nfs /home/#{user}/rails/plugins/ez_where #{release_path}/vendor/plugins/ez_where"
end

task :acts_as_ferret, :roles => :web do
	puts "acts_as_ferret ..."
	run "ln -nfs /home/#{user}/rails/plugins/acts_as_ferret #{release_path}/vendor/plugins/acts_as_ferret"
end

task :error_messages_for, :roles => :web do
	puts "error_messages_for ..."
	run "ln -nfs /home/#{user}/rails/plugins/error_messages_for #{release_path}/vendor/plugins/error_messages_for"
end

task :unicode_hacks, :roles => :web do
	puts "unicode_hacks ..."
	run "ln -nfs /home/#{user}/rails/plugins/unicode_hacks #{release_path}/vendor/plugins/unicode_hacks"
end

task :acts_as_attachment, :roles => :web do
	puts "acts_as_attachment ..."
	run "ln -nfs /home/#{user}/rails/plugins/acts_as_attachment #{release_path}/vendor/plugins/acts_as_attachment"
end


#################################################
# TAIL
#################################################

desc 'tail production log files'
task :tail_logs, :roles => :app do
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    puts
    puts "#{channel[:host]} #{data}"
    break if stream == :err
  end
  
end

desc "dreamhost deploy task"
task :deploy_on_ovh, :roles => :web do
	transaction do
		update_code
		symlink
		puts "Changing permissions ..."
		run "chmod 755 #{root}/public/dispatch.fcgi"
		run "chmod 755 #{root}/public/.htaccess"
		puts "Database settings ..."
		run "mv #{root}/config/database.ovh.yml #{root}/config/database.yml"
	end
end

task :after_symlink, :roles => :web do
  symlink_plugins
  run "mv #{root}/config/database.ovh.yml #{root}/config/database.yml"
end

desc "Restarting mod_rails with restart.txt"
task :restart, :roles => :app, :except => { :no_release => true } do
  sudo "/etc/init.d/cf2010 restart"
end