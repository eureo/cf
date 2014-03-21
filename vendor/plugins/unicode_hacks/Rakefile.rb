require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'activesupport_mb/lib'
  t.test_files = FileList['test/t_*.rb', 'activesupport_mb/test/multibyte/*.rb', 'actionpack_mb/test/controller/*.rb']
  t.verbose = true
end

PKG_RDOC_OPTS = ['--main=README',
                 '--line-numbers',
                 '--charset=utf-8',
                 '--promiscuous']


desc 'Generate documentation'
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'UnicodeHacks. Reloaded.'
  rdoc.options  = PKG_RDOC_OPTS
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('activesupport_mb/lib/**/*.rb')
  rdoc.rdoc_files.include('actionpack_mb/lib/**/*.rb')
  rdoc.rdoc_files.include('LICENSE')
  rdoc.rdoc_files.include('UNICODE_PRIMER')
  rdoc.rdoc_files.exclude('lib/complete_overrides.rb')
  rdoc.rdoc_files.exclude('activesupport_mb/lib/active_support/multibyte/handlers/utf8_handler_pure_tables.rb')
end

desc "Sends the new docs to the server"
task :publish_docs => [:doc] do
  `rsync -arvz ./doc/ julik@julik.nl:~/public_html/code/unicode-hacks/`
end
