module UnicodeFilters
  module InstanceMethods
    # Tells the database that we want to speak to it in UTF8
    def configure_database_charsets
      #return true unless ActiveRecord::Base.connection.respond_to?(:setup_unicode_client)
      #  rescue ActiveRecord::ConnectionNotEstablished
      begin
        return true unless ActiveRecord::Base.connection.respond_to?(:setup_unicode_client)
      rescue ActiveRecord::ConnectionNotEstablished
        return true
      end
      
      begin
        ActiveRecord::Base.connection.setup_unicode_client
      rescue ActiveRecord::StatementInvalid => e
        if e.to_s =~ /away/
          ActiveRecord::Base.establish_connection
          retry
        else
          raise e
        end
      end
    end

    # Appends the needed charset to the response headers (Safari spooges RJS responses unless they
    # have their Charset header properly set)
    # Besides, every browser will *restart parsing your document* if you use the meta-tag only
    def append_charset_to_headers
  # return true unless $KCODE == 'UTF8'
      return true
  # 
  # headers["Content-Type"] ||= "text/html; charset=UTF-8"
  # if (headers["Content-Type"].include?('text/') || headers["Content-Type"].include?('application/')) && !headers["Content-Type"].include?('charset')
  #   headers["Content-Type"] += "; charset=UTF-8"
  # end
    end
  end
end