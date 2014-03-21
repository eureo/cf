class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter < ActiveRecord::ConnectionAdapters::AbstractAdapter #:nodoc:
  # Sends SET CLIENT_ENCODING to Postgres
  def setup_unicode_client
    execute("SET CLIENT_ENCODING TO UNICODE")
  end
end

class ActiveRecord::ConnectionAdapters::MysqlAdapter < ActiveRecord::ConnectionAdapters::AbstractAdapter #:nodoc:
  # Sends SET NAMES UTF8 to MySQL
  def setup_unicode_client
    execute("SET NAMES UTF8")
  end
end

begin
  ActiveRecord::Base.establish_connection
  if ActiveRecord::Base.connection.respond_to?(:setup_unicode_client)
    ActiveRecord::Base.connection.setup_unicode_client
  end
rescue ActiveRecord::AdapterNotSpecified
end