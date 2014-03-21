ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = false

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = true

  # Add more helper methods to be used by all tests here...
	#
	
	
	def test_creation_of(options)
		raise NotTheRightOptions.new('Options must include a record, a fixture, and an array of attributes') if (options.keys | [:record, :fixture, :attributes]).size > options.size
		assert_kind_of options[:model], options[:record] if options[:model]
		for attr in options[:attributes]
			assert_equal options[:record][attr], options[:fixture].send(attr), "Error matching #{attr}"
		end
	end

	def test_updating_of(options)
		raise NotTheRightOptions.new('Options must include a record, a fixture, and an attribute') if (options.keys | [:record, :fixture, :attribute]).size > options.size
		options[:record][options[:attribute]] = options[:fixture]
		assert options[:record].save, options[:record].errors.full_messages.join('; ')
		options[:record].reload
		assert_equal options[:fixture], options[:record].send(options[:attribute])
	end

	def test_destruction_of(options)
		raise NotTheRightOptions.new('Options must include a record and a model') if (options.keys | [:record, :model]).size > options.size
		old_count = options[:model].count
		options[:record].destroy
		assert_equal old_count-1, options[:model].count
		assert_raise(ActiveRecord::RecordNotFound){ options[:model].find(options[:record].id) }
	end
	
end
