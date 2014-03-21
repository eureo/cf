class ActiveSupport::Multibyte::Handlers::UTF8HandlerIcu < ActiveSupport::Multibyte::Handlers::UTF8Handler
  
  class << self
    def self.bypass_to_ustr(meth, as = nil)
      as ||= meth
      define_method(meth) do | str |
        str.u.send(as).to_s
      end
    end

    bypass_to_ustr :normalize_D, :norm_D
    bypass_to_ustr :normalize_C, :norm_C
    bypass_to_ustr :normalize_KC, :norm_KC
    bypass_to_ustr :normalize_KD, :norm_KD
    bypass_to_ustr :decompose, :norm_D
    
    def size(str)
      str.u.size
    end
    
    def downcase(str)
      str.u.downcase.to_s
    end

    def upcase(str)
      str.u.upcase.to_s
    end
  end
end