require File.dirname(__FILE__) + '/handlers/utf8_handler'

# Encapsulates all the functionality related to the Chars proxy.
module ActiveSupport::Multibyte
  DEFAULT_NORMALIZATION_FORM = 'KC'
  
  # Methods in this module are mixed into the String class. Defines the accessor for the characters proxy.
  module StringExtensions
    # +chars+ is the accessor for the Chars proxy class. It returns a Chars object that encapsulates the string on
    # which Unicode safe string operations can be performed. If ICU4R isn't loaded, this method is also aliased as +u+.
    def chars
      ActiveSupport::Multibyte::Chars.new(self)
    end
    
    # ICU4R also defines a +u+ on the string class, we don't want to interfere with that
    unless String.instance_methods.include?("u")
      alias_method :u, :chars
    end
    
    # Returns true if the string has UTF-8 semantics (a String used for purely byte resources is unlikely to have
    # them), returns false otherwise.
    def is_utf8?
      ActiveSupport::Multibyte::Handlers::UTF8Handler.consumes?(self)
    end
  end

  # Chars enables you to work transparently with multibyte encodings in the Ruby String class without having extensive
  # knowledge about the encoding. A Chars object accepts a string upon initialization and proxies String methods in an
  # encoding safe manner. All the normal String methods are also implemented on the proxy.
  #
  # The actual operations on the string are delegated to handlers. Theoretically handlers can be implemented for
  # any encoding, currently only UTF-8 handlers are implemented. During initialization the module chooses an
  # optimal handler for the Chars class, but you can easily override the handler setting.
  #
  #   Chars.handler = :UTF8HandlerProc
  #
  # String methods are proxied through the Chars object, and can be accessed through the +chars+ method. Methods
  # which would normally return a String object now return a Chars object so methods can be chained.
  #
  #  "The Perfect String  ".chars.downcase.strip.normalize #=> "the perfect string"
  #
  # Chars objects are perfectly interchangeable with String objects as long as no explicit class checks are made.
  # If certain methods do explicitly check the class, call +to_s+ before you pass the object to them.
  #
  #  bad.explicit_checking_method "T".chars.downcase.to_s
  #
  class Chars
    attr_reader :string # The contained string
    alias_method :to_s, :string
    alias_method :raw_string, :string
    
    # The magic method to make String believe we can be compared to it. Using any other ways
    # of overriding the String itself will lead you all the way from infinite loops to
    # core dumps. Don't go there.
    def to_str
      @string
    end

    include Comparable
    
    # Returns -1, 0 or +1 depending on whether the Chars object is to be sorted before, equal or after the
    # object on the right side of the operation. It accepts any object that implements +to_s+. See String.<=>
    # for more details.
    def <=>(other)
      @string <=> (other.to_s)
    end

    # Create a new Chars instance
    def initialize(with_str)
      @string = (with_str.string rescue with_str)
    end

    # Forwards all missing methods to the handler. Ff the handler doesn't define the method either, the call is
    # forwarded to the contained string instance.
    def method_missing(*all)
      begin
        args = all.dup
        meth = args.shift
        handler.send(meth, @string, *args)
      rescue NoMethodError
        @string.send(*all)
      end
    end

    # gsub is also present in Kernel
    def gsub(*args) #:nodoc:
      @string.gsub(*args)
    end

    # Returns the KC normalization of the string. NFKC is considered the best normalization form for
    # passing strings to databases and validations.
    def normalize(form = nil)
      form ||= DEFAULT_NORMALIZATION_FORM
      forward(handler.send("normalize_#{form}", @string))
    end

    # Normalizes the internal string.
    def normalize!(form = nil)
      form ||= DEFAULT_NORMALIZATION_FORM
      @string.replace( handler.send("normalize_#{form}", @string) )
    end
  
    # Performs charset-aware conversion to lowercase.
    def downcase
      forward(handler.downcase(@string))
    end

    # Performs charset-aware conversion to lowercase on the internal string.
    def downcase!
      @string.replace(downcase.string)
    end

    # Performs charset-aware conversion to UPPERCASE
    def upcase
      forward(handler.upcase(@string))
    end

    # Performs charset-aware conversion to UPPERCASE on the internal string.
    def upcase!
      @string.replace(handler.upcase(@string))
    end

    # Returns the D normalization of the string.
    def decompose
      forward(handler.decompose(@string))
    end

    # Performs charset-aware Capitalization
    def capitalize
      forward(handler.capitalize(@string))
    end

    # Performs charset-aware Capitalization on the internal string.
    def capitalize!
      @string.replace capitalize.to_s
    end

    # Splits the string on whitespace, passing each substring in turn to the supplied block. This differs from 
    # String#each that it doesn't use the global record separator to separate the string.
    def each(&block)
      @string.split(//).each{ | g | yield(g) }
    end


    # Like String.slice, only it slices on character boundaries instead of bytes.
    def slice(*args)
      return handler.slice(@string, *args)
    end

    def [](*args) #:nodoc:
      slice(*args)
    end

    # Like String.index, only this returns index in codepoints from the start of the string.
    def index(*args)
      handler.index(@string, *args)
    end
    
    # Translates the +byte_offset+ into a character offset. If the byte_offset falls in a character, the offset of
    # that character is returned.
    def translate_offset(byte_offset)
      handler.translate_offset(@string, byte_offset)
    end
    
    # Like String.=~ only it returns the character offset instead of the byte offset.
    def =~(other)
      byte_offset = @string =~ other
      byte_offset ? translate_offset(byte_offset) : nil
    end

    # Replacement for the strip routine. Will first normalize the string and then remove all Unicode whitespace,
    # including line breaks and nonbreaking spaces.
    def strip
      forward(handler.strip(@string))
    end

    # Replacement for the lstrip routine. Will first normalize the string and then remove all Unicode whitespace,
    # including line breaks and nonbreaking spaces.
    def lstrip
      forward(handler.lstrip(@string))
    end

    # Replacement for the rstrip routine. Will first normalize the string and then remove all Unicode whitespace,
    # including line breaks and nonbreaking spaces.
    def rstrip
      forward(handler.rstrip(@string))
    end

    # Performs lstrip on the internal string and replaces it with the result.
    def lstrip!
      @string.replace lstrip.to_s
    end

    # Performs rstrip on the internal string and replaces it with the result.
    def rstrip!
      @string.replace rstrip.to_s
    end

    # Performs strip on the internal string and replaces it with the result.
    def strip!
      @string.replace strip.to_s
    end

    # Provides replacement for the size routine. Will first normalize to KC and then return the number
    # of codepoints.
    def size
      handler.size(@string)
    end

    alias_method :length, :size

    # Replacement for the reverse routine. Will first normalize to KC and then reverse the resulting
    # codepoints.
    def reverse
      forward(handler.reverse(@string))
    end

    # Splits the string on codepoints boundaries instead of byte boundaries.
    def split(*args)
      handler.split(@string, *args).map{|c| forward(c) }
    end

    # Inserts the string at codepoint offset.
    def insert(offset, fragment)    
      forward(handler.insert(@string, offset, fragment))
    end

    # Set the handler class for the Char objects. Normally the optimal handler is chosen by the module, but you can
    # override it if you want to. Accepts a symbol of the class, ie. :UTF8HandlerPure
    def self.handler=(klass)
      @@handler = klass
    end

    private
      # Packs the result in a Chars object so methods can be chained on the result.
      def forward(string_result)
        string_result.chars
      end
      
      # +utf8_pragma+ checks if it can send this string to the handlers. First is checks if @string isn't nil. Then it
      # checks if KCODE is set and finally it does a quick check if the string is encoded in UTF-8.
      def utf8_pragma?
        @string && ($KCODE == 'UTF8') && @string.is_utf8?
      end


      # Selects the proper handler for the contained string depending on KCODE and the encoding of the string.
      def handler #:doc
        if utf8_pragma?
          @@handler
        else
          ActiveSupport::Multibyte::Handlers::PassthruHandler
        end
      end
  end
  
  
  module Handlers
  end

  possible_handlers = [
    ['icu4r',           [File.dirname(__FILE__) + '/handlers/utf8_handler_icu'],          :UTF8HandlerIcu],
    ['utf8proc_native', [File.dirname(__FILE__) + '/handlers/utf8_handler_proc'],         :UTF8HandlerProc],
    ['unicode',         [File.dirname(__FILE__) + '/handlers/utf8_handler_unicode_ext'],  :UTF8HandlerUnicodeExt],
    [nil,               [File.dirname(__FILE__) + '/handlers/utf8_handler_pure2'],        :UTF8HandlerPure2],
    [nil,               [File.dirname(__FILE__) + '/handlers/utf8_handler_pure_tables',
                         File.dirname(__FILE__) + '/handlers/utf8_handler_pure'],         :UTF8HandlerPure],
  ]
  
  possible_handlers.each do | extlib, libs, const |
    begin
      require_library_or_gem(extlib) if extlib
    rescue LoadError
      $stderr.puts "Can't load handler #{const}"
      next
    end
    libs.each { | lib | require lib }
    $stderr.puts "Using handler #{const}"
    Chars.handler = Handlers::const_get(const)
    break
  end
end

class String
  include ActiveSupport::Multibyte::StringExtensions
end
