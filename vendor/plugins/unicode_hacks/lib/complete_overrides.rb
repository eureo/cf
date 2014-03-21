begin
  require 'unicode'
  # This is NOT supported and WILL break stuff.
  #
  # Left in the repository for historical reasons.
  #
  # Do some SUBSTANTIAL rewiring of the String class. This doesn't solve all of the problems
  # but it does solve some. And it will work in UTF-8 context only, so we step aside
  # if $KCODE is not UTF-8 (Japanese people prefr JIS, right?)
  #
  # Following the tradition - I am grateful to Yoshida MASATO for the Unicode gem.
  #
  # The core capabilities of String are changed by this module only when $KCODE is set to 'UTF8'.
  # Strings start to properly trim, properly strip and size, and do many other nice things they have
  # been supposed to do for ages.
  # All "old" byte-oriented methods of Strings are still available with "byte_" prefix (i.e. "byte_reverse", "byte_slice")
  class Object::String
  end
  
  unless defined?(String::UNICODE_REWIRED) # rewire only once even if it's reloaded
    class Object::String
      @@hacks_off = false
      
      UNICODE_REWIRED = true #:nodoc:

      class <<self
        # Returns a regular expression pattern that matches the passed Unicode codepoints
        def codepoints_to_pattern(array_of_codepoints)
          array_of_codepoints.collect{ |e| [e].pack "U*" }.join('|') 
        end
        
        def without_hacks(&block)
          old_utf = @@hacks_off
          begin
            @@hacks_off = true
            yield
          ensure
            @@hacks_off = old_utf
          end
        end
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
      ].flatten  #:nodoc:
      
      UNICODE_LEADERS_AND_TRAILERS = UNICODE_WHITESPACE + [65279] # ZERO-WIDTH NO-BREAK SPACE aka BOM  #:nodoc:
      
      # Borrowed from the Kconv library by Shinji KONO - (also as seen on the W3C site)
      UTF8_PAT = /\A(?:
                    [\x00-\x7f]                                     |
                    [\xc2-\xdf] [\x80-\xbf]                         |
                    \xe0        [\xa0-\xbf] [\x80-\xbf]             |
                    [\xe1-\xef] [\x80-\xbf] [\x80-\xbf]             |
                    \xf0        [\x90-\xbf] [\x80-\xbf] [\x80-\xbf] |
                    [\xf1-\xf3] [\x80-\xbf] [\x80-\xbf] [\x80-\xbf] |
                    \xf4        [\x80-\x8f] [\x80-\xbf] [\x80-\xbf]
                   )*\z/xn    #:nodoc:
      
      
      UNICODE_TRAILERS_PAT = /(#{codepoints_to_pattern(UNICODE_LEADERS_AND_TRAILERS)})+$/  #:nodoc:
      UNICODE_LEADERS_PAT = /^(#{codepoints_to_pattern(UNICODE_LEADERS_AND_TRAILERS)})+/ #:nodoc:
          
      alias :byte_downcase :downcase
      # Performs Unicode-aware conversion to lowercase
      def downcase #:nodoc:
        return byte_downcase unless utf8_pragma?
        
        Unicode::downcase(Unicode::normalize_KC(self))
      end

      def downcase! #:nodoc:
         self.replace downcase
      end

      alias :byte_upcase :upcase
      # Performs Unicode-aware conversion to UPPERCASE
      def upcase #:nodoc:
        return byte_upcase unless utf8_pragma?
        
        Unicode::upcase(Unicode::normalize_KC(self))
      end

      def upcase! #:nodoc:
         self.replace upcase
      end

      alias_method :byte_capitalize, :capitalize
       
      # Performs Unicode-aware Capitalization
      def capitalize #:nodoc:
        byte_capitalize unless utf8_pragma?
        
        Unicode::capitalize(Unicode::normalize_KC(self))
      end

      def capitalize! #:nodoc:
         self.replace capitalize
      end

      alias_method :byte_slice, :slice
      # Instead of fetching bytes will fetch the string composed of codepoints at the specified offsets.
      # The call with a single integer as argument will still return a byte.
      # If the string is not a valid UTF-8 sequence bytes will be returned
      def slice(*args) #:nodoc:
        return byte_slice(*args) unless utf8_pragma?
      
        if (args.size == 2 && args.first.is_a?(Range))
          raise TypeError, 'cannot convert Range into Integer' # Do as if we were native
        elsif (args.first.is_a?(Range) or args.size == 2)
          #normalize to KC so that all combined glyphs are spliced together and ligatures split, and then....
          Unicode::normalize_KC(self).unpack("U*").send(:slice, *args).pack("U*")
        else
          byte_slice(*args)
        end
      end
    
      def [](*args) #:nodoc:
        slice(*args)
      end
            
      alias_method :byte_index, :index
      def index(*args) #:nodoc:
        if (args.first.is_a?(String) and !args.first.has_utf8_semantics?) or !utf8_pragma?
          return byte_index(*args)
        end

        bidx = byte_index(*args)
        return nil unless bidx
        return self.byte_slice(0...bidx).unpack("U*").size
      end

      # Replacement for the lstrip routine. Will first normalize the string and then remove all Unicode whitespace,
      # including line breaks and nonbreaking spaces      
      alias :byte_strip :strip
      def strip #:nodoc:
        return byte_strip unless utf8_pragma?
        
        lstrip.rstrip
      end
    
      # Replacement for the lstrip routine. Will first normalize the string and then remove all Unicode whitespace,
      # including line breaks and nonbreaking spaces      
      alias :byte_lstrip :lstrip
      def lstrip #:nodoc:
        return byte_lstrip unless utf8_pragma?
        
        gsub(UNICODE_LEADERS_PAT, '')
      end
            
      # Replacement for the rstrip routine. Will first normalize the string and then remove all Unicode whitespace,
      # including line breaks and nonbreaking spaces
      alias :byte_rstrip :rstrip
      def rstrip #:nodoc:
        return byte_rstrip unless utf8_pragma?
        
        gsub(UNICODE_TRAILERS_PAT, '')
      end
      
      def lstrip! #:nodoc:
        self.replace lstrip
      end

      def rstrip! #:nodoc:
        self.replace rstrip
      end

      def strip! #:nodoc:
        self.replace strip
      end

      # Decomposes the string and returns the decomposed string      
      def decompose #:nodoc:
        Unicode::decompose(self)
      end
    
      # Normalizes the string to form KC and returns the result
      def normalize_KC #:nodoc:
        Unicode::normalize_KC(self)
      end

      # Normalizes the string to form D and returns the result
      def normalize_D #:nodoc:
        Unicode::normalize_D(self)
      end

      # Normalizes the string to form C and returns the result
      def normalize_C #:nodoc:
        Unicode::normalize_C(self)
      end

      # Provides replacement for the size routine. Will first normalize to KC and then return the number
      # of codepoints
      alias_method :byte_size, :size    
      def size #:nodoc:
        return byte_size unless utf8_pragma?

        #normalize to KC so that all combiner letters are spliced together, and then....
        Unicode::normalize_KC(self).unpack("U*").size
      end
      
      def length #:nodoc:
        size
      end

      
      # Provides replacement for the reverse routine. Will first normalize to KC and then reverse the resulting
      # codepoints
      alias_method :byte_reverse, :reverse
      def reverse  #:nodoc:
        return byte_reverse unless utf8_pragma?
      
        Unicode::normalize_KC(self).unpack("U*").reverse.pack("U*")
      end

      alias_method :byte_insert, :insert
      # Inserts the string at codepoint offset specified in offset.
      def insert(offset, fragment)  #:nodoc:
        return byte_insert(offset, fragment) unless utf8_pragma?
        
        self.replace(unpack("U*").insert(offset, fragment.unpack("U*")).flatten.pack("U*"))
      end
      
      # Returns false or true depending on whether the string has UTF-8 semantics (a String used for purely 
      # byte resources is unlikely to have them).
      def has_utf8_semantics? #:nodoc:
        UTF8_PAT.match(self)
      end
            
      private
        def utf8_pragma? #:nodoc:
          ($KCODE == 'UTF8') and !@@hacks_off and (self.has_utf8_semantics?)
        end
    end

    if defined?(RAILS_DEFAULT_LOGGER)  
      RAILS_DEFAULT_LOGGER.warn "Standard string functions have been overloaded with " +
                                "UTF8-aware versions"
    end
  end
  
  # introduce some quick hacks to counteract the extreme measures we just took.
  # If there is something to hate Ruby for it's the fact that we have to do all this.
  
  # CGI::escape relies on byte size
  def CGI::escape(string) #:nodoc:
    string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
      '%' + $1.unpack('H2' * $1.byte_size).join('%').upcase
    end.tr(' ', '+')
  end
  
  # ERB compiler chops strings before blocks
  class ERB::Compiler # :nodoc:
    alias_method :compile_without_utf, :compile
    def compile(s)
      String.without_hacks do 
        compile_without_utf(s)
      end
    end
  end

rescue LoadError
  if defined?(RAILS_DEFAULT_LOGGER)  
    RAILS_DEFAULT_LOGGER.error "You don't have the Unicode library installed, most string " +
                               "operations will stay single-byte"
  end
end