# Works as a passthrough implementation - just calls the methods on Strings
class ActiveSupport::Multibyte::Handlers::PassthruHandler
  def self.method_missing(message, string, *extras)
    string.send(message, *extras)
  end
  
  def self.translate_offset(string, byte_offset)
    byte_offset
  end
end