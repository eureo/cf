# Implements Unicode-aware operations for strings, will be used by Chars when $KCODE is set to 'UTF8'
# As a rule, accepts the string to be processed as a first argument, and the other arguments after that.
# More savvy implementations have more to offer :-)
class ActiveSupport::Multibyte::Handlers::UTF8Handler
  
  # Returns a regular expression pattern that matches the passed Unicode codepoints
  def self.codepoints_to_pattern(array_of_codepoints)
    array_of_codepoints.collect{ |e| [e].pack "U*" }.join('|') 
  end
  
  UNICODE_WHITESPACE = [
    (0x0009..0x000D).to_a,  # White_Space # Cc   [5] <control-0009>..<control-000D>
    0x0020,          # White_Space # Zs       SPACE
    0x0085,          # White_Space # Cc       <control-0085>
    0x00A0,          # White_Space # Zs       NO-BREAK SPACE
    0x1680,          # White_Space # Zs       OGHAM SPACE MARK
    0x180E,          # White_Space # Zs       MONGOLIAN VOWEL SEPARATOR
    (0x2000..0x200A).to_a, # White_Space # Zs  [11] EN QUAD..HAIR SPACE
    0x2028,          # White_Space # Zl       LINE SEPARATOR
    0x2029,          # White_Space # Zp       PARAGRAPH SEPARATOR
    0x202F,          # White_Space # Zs       NARROW NO-BREAK SPACE
    0x205F,          # White_Space # Zs       MEDIUM MATHEMATICAL SPACE
    0x3000,          # White_Space # Zs       IDEOGRAPHIC SPACE
  ].flatten
  
  # BOM is also whitespace because it's irrelevant for UTF-8
  UNICODE_LEADERS_AND_TRAILERS = UNICODE_WHITESPACE + [65279] # ZERO-WIDTH NO-BREAK SPACE aka BOM
  
  # Borrowed from the Kconv library by Shinji KONO - (also as seen on the W3C site)
  UTF8_PAT = /\A(?:
                [\x00-\x7f]                                     |
                [\xc2-\xdf] [\x80-\xbf]                         |
                \xe0        [\xa0-\xbf] [\x80-\xbf]             |
                [\xe1-\xef] [\x80-\xbf] [\x80-\xbf]             |
                \xf0        [\x90-\xbf] [\x80-\xbf] [\x80-\xbf] |
                [\xf1-\xf3] [\x80-\xbf] [\x80-\xbf] [\x80-\xbf] |
                \xf4        [\x80-\x8f] [\x80-\xbf] [\x80-\xbf]
               )*\z/xn   
  
  
  UNICODE_TRAILERS_PAT = /(#{codepoints_to_pattern(UNICODE_LEADERS_AND_TRAILERS)})+\Z/
  UNICODE_LEADERS_PAT = /\A(#{codepoints_to_pattern(UNICODE_LEADERS_AND_TRAILERS)})+/


  class << self
        
    # Checks if the string is valid UTF8. Uses unpack which is somewhat faster than pattern matching.
    def consumes?(str)
      begin
        str.unpack("U*")
        true
      rescue ArgumentError
        false
      end
    end
    
    def bypass(str); return str; end
      
    # Inserts the passed string at specified codepoint offsets
    def insert(str, offset, fragment)
      str.replace(str.unpack("U*").insert(offset, fragment.unpack("U*")).flatten.pack("U*"))
    end

    # Returns the position of the passed argument in the string, counting in codepoints
    def index(str, *args)
      bidx = str.index(*args)
      bidx ? (str.slice(0...bidx).unpack("U*").size) : nil
    end
    
    # Does Unicode-aware rstrip
    def rstrip(str)
      str.gsub(UNICODE_TRAILERS_PAT, '')
    end

    # Does Unicode-aware lstrip
    def lstrip(str)
      str.gsub(UNICODE_LEADERS_PAT, '')
    end
    
    alias_method :downcase, :bypass
    alias_method :upcase, :bypass
    alias_method :capitalize, :bypass
    
    # Returns the real length of the string in codepoints.
    def size(str)
      str.unpack("U*").size
    end
    alias_method :length, :size

    # Will strip all funky Unicode whitespace from the start and end of the string        
    def strip(str)
      str.gsub(UNICODE_LEADERS_PAT, '').gsub(UNICODE_TRAILERS_PAT, '')
    end

    # Will reverse the characters. To handle ligatures the string will be split beforehand,
    # provided the module is available    
    def reverse(str)
      str.unpack("U*").reverse.pack("U*")
    end
    
    # Implements Unicode-aware slice with codepoints.
    def slice(str, *args)
      if (args.size == 2 && args.first.is_a?(Range))
        raise TypeError, 'cannot convert Range into Integer' # Do as if we were native
      elsif (args.first.is_a?(Range) or args.size == 2)
        str.unpack("U*").slice(*args).pack("U*") rescue nil
      else
        str.slice(*args)
      end
    end
        
    # Used to translate an offset from bytes to characters,
    # for instance one recieved from a regular expression match
    def translate_offset(str, byte_offset)
      chunk = str[0..byte_offset]
      begin
        chunk.unpack("U*").length - 1
      rescue ArgumentError # we damaged a character
        chunk = str[0..(byte_offset+=1)]
        retry
      end
    end

    NORMALIZATION_METHODS = [
     :normalize_D,
     :normalize_C,
     :normalize_KC,
     :normalize_KD,
     :decompose
    ]
    
    NORMALIZATION_METHODS.each do | meth |
      alias_method meth, :bypass
    end
    
    # Splits the string on the passed Regexp, normalizing to KC beforehand if the module is available
    def split(str, on)
      str.split(on)
    end
  end
end