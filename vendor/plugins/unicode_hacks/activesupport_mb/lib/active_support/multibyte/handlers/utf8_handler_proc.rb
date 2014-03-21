class ActiveSupport::Multibyte::Handlers::UTF8HandlerProc < ActiveSupport::Multibyte::Handlers::UTF8Handler
  
  class << self
    def utf8map(str, *option_array)
      options = 0
      option_array.each do |option|
        flag = Utf8Proc::Options[option]
        raise ArgumentError, "Unknown argument given to utf8map." unless
          flag
        options |= flag
      end
      return Utf8Proc::utf8map(str, options)
    end
    
    def normalize_D(str)
      utf8map(str, :stable)
    end
    
    def normalize_C(str)
      utf8map(str, :stable, :compose)
    end
    
    def normalize_KD(str)
      utf8map(str, :stable, :compat)
    end
    
    def normalize_KC(str)
      utf8map(str, :stable, :compose, :compat)
    end
    
    alias_method :decompose, :normalize_D
    
    def downcase(str)
      utf8map(str, :casefold)
    end
    
  # def upcase(str) - this has Buggz!
  #   utf8map(str, :casefold)
  # end
  end
end
