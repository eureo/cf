class ActiveSupport::Multibyte::Handlers::UTF8HandlerUnicodeExt < ActiveSupport::Multibyte::Handlers::UTF8Handler
  class << self
    def self.bypass_to_module(meth)
      define_method(meth) do | string |
        Unicode.send(meth, string)
      end
    end
    
    bypass_to_module :normalize_D
    bypass_to_module :normalize_C
    bypass_to_module :normalize_KD
    bypass_to_module :normalize_KC
    alias_method :decompose, :normalize_D
    
    def downcase(str)
      Unicode::downcase(str)
    end
    
    def upcase(str)
      Unicode::upcase(str)
    end
    
  end
end
