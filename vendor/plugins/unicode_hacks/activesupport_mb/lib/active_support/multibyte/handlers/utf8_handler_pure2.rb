module ActiveSupport::Multibyte::Handlers
  class Codepoint
    attr_accessor :code, :combining_class, :decomp_type, :decomp_mapping, :uppercase_mapping, :lowercase_mapping
  end
  
  class UnicodeDatabase
    attr_accessor :codepoints, :composition_exclusion, :composition_map, :boundary
    
    def initialize
      begin
        @codepoints, @composition_exclusion, @composition_map, @boundary = self.class.load
      rescue Exception => e
        $stderr.puts "Couldn't load the unicode tables for UTF8HandlerPure2 (#{e.to_s}), handler is unusable"
      end
      @codepoints ||= Hash.new(Codepoint.new)
      @composition_exclusion ||= []
      @composition_map ||= {}
      @boundary ||= {}

      @boundary.each do |k,_|
        @boundary[k].instance_eval do
          def ===(other)
            detect { |i| i === other } ? true : false
          end
        end if @boundary[k].kind_of?(Array)
      end
    end
    
    def [](index)
      @codepoints[index]
    end
    
    def self.filename
      File.expand_path(File.dirname(__FILE__) + '/../../values/unicode_tables.dat')
    end
    
    def self.load
      File.open(self.filename) { |f| Marshal.load f.read }
    end
  end
  
  class UTF8HandlerPure2 < UTF8Handler
    # UniCode Database
    UCD = UnicodeDatabase.new
    
    HANGUL_SBASE = 0xAC00
    HANGUL_LBASE = 0x1100
    HANGUL_VBASE = 0x1161
    HANGUL_TBASE = 0x11A7
    HANGUL_LCOUNT = 19
    HANGUL_VCOUNT = 21
    HANGUL_TCOUNT = 28
    HANGUL_NCOUNT = HANGUL_VCOUNT * HANGUL_TCOUNT
    HANGUL_SCOUNT = 11172
    HANGUL_SLAST = HANGUL_SBASE + HANGUL_SCOUNT
    HANGUL_JAMO_FIRST = 0x1100
    HANGUL_JAMO_LAST = 0x11FF
    
    class << self
      
      public
      
      [:d, :c, :kd, :kc].each do |type|
        define_method "normalize_#{type.to_s.upcase}" do |str|
          perform_normalization type, str
        end
      end

      # Returns the number of grapheme clusters in the string.
      def length(str)
        g_unpack(str).length
      end
      alias_method :g_length, :length
      
      def upcase(str); to_case :uppercase_mapping, str; end
      
      def downcase(str); to_case :lowercase_mapping, str; end
      
      def decompose(str)
        decompose_codepoints(:canonical, str.unpack('U*')).pack('U*')
      end
      
      def compose(str)
        compose_codepoints str.unpack('U*').pack('U*')
      end
      
      def split(str, on)
        str.split(on)
      end
      
      private

      def in_char_class?(codepoint, classes)
        classes.detect { |c| UCD.boundary[c] === codepoint } ? true : false
      end
      
      # Unpack the string at grapheme boundaries instead of codepoint boundaries
      def g_unpack(str)
        codepoints = str.unpack('U*')
        unpacked = []
        pos = 0
        marker = 0
        eoc = codepoints.length
        while(pos < eoc)
          pos += 1
          previous = codepoints[pos-1]
          current = codepoints[pos]
          if (
              # CR X LF
              one = ( previous == UCD.boundary[:cr] and current == UCD.boundary[:lf] ) or
              # L X (L|V|LV|LVT)
              two = ( UCD.boundary[:l] === previous and in_char_class?(current, [:l,:v,:lv,:lvt]) ) or
              # (LV|V) X (V|T)
              three = ( in_char_class?(previous, [:lv,:v]) and in_char_class?(current, [:v,:t]) ) or
              # (LVT|T) X (T)
              four = ( in_char_class?(previous, [:lvt,:t]) and UCD.boundary[:t] === current ) or
              # X Extend
              five = (UCD.boundary[:extend] === current)
            )
          else
            unpacked << codepoints[marker..pos-1]
            marker = pos
          end
        end 
        unpacked
      end
      
      def g_pack(unpacked)
        unpacked.flatten
      end
      
      def to_case(way, str)
        str.unpack('U*').map do |codepoint|
          cp = UCD[codepoint] 
          unless cp.nil?
            ncp = cp.send(way)
            ncp > 0 ? ncp : codepoint
          else
            codepoint
          end
        end.pack('U*')
      end
      
      def reorder_characters(codepoints)
        length = codepoints.length- 1
        pos = 0
        while pos < length do
          cp1, cp2 = UCD[codepoints[pos]], UCD[codepoints[pos+1]]
          if (cp1.combining_class > cp2.combining_class) && (cp2.combining_class > 0)
            codepoints[pos..pos+1] = cp2.code, cp1.code
            pos += (pos > 0 ? -1 : 1)
          else
            pos += 1
          end
        end
        codepoints
      end
      
      def decompose_codepoints(type, codepoints)
        codepoints.inject([]) do |decomposed, cp|
          # if it's a hangul syllable starter character
          if HANGUL_SBASE <= cp and cp < HANGUL_SLAST
            sindex = cp - HANGUL_SBASE
            ncp = [] # new codepoints
            ncp << HANGUL_LBASE + sindex / HANGUL_NCOUNT
            ncp << HANGUL_VBASE + (sindex % HANGUL_NCOUNT) / HANGUL_TCOUNT
            tindex = sindex % HANGUL_TCOUNT
            ncp << (HANGUL_TBASE + tindex) unless tindex == 0
            decomposed.concat ncp
          # if the codepoint is decomposable in with the current decomposition type
          elsif (ncp = UCD[cp].decomp_mapping) and (!UCD[cp].decomp_type || type == :compatability)
            decomposed.concat decompose_codepoints(type, ncp.dup)
          else
            decomposed << cp
          end
        end
      end
      
      def compose_codepoints(codepoints)
        pos = 0
        eoa = codepoints.length - 1
        starter_pos = 0
        starter_char = codepoints[0]
        previous_combining_class = -1
        while pos < eoa
          pos += 1
          lindex = starter_char - HANGUL_LBASE
          # -- Hangul
          if 0 <= lindex and lindex < HANGUL_LCOUNT
            vindex = codepoints[starter_pos+1] - HANGUL_VBASE rescue vindex = -1
            if 0 <= vindex and vindex < HANGUL_VCOUNT
              tindex = codepoints[starter_pos+2] - HANGUL_TBASE rescue tindex = -1
              if 0 <= tindex and tindex < HANGUL_TCOUNT
                j = starter_pos + 2
                eoa -= 2
              else
                tindex = 0
                j = starter_pos + 1
                eoa -= 1
              end
              codepoints[starter_pos..j] = (lindex * HANGUL_VCOUNT + vindex) * HANGUL_TCOUNT + tindex + HANGUL_SBASE
            end
            starter_pos += 1
            starter_char = codepoints[starter_pos]
          # -- Other characters
          else
            current_char = codepoints[pos]
            current = UCD[current_char]
            if current.combining_class > previous_combining_class
              if ref = UCD.composition_map[starter_char]
                composition = ref[current_char]
              else
                composition = nil
              end
              unless composition.nil?
                codepoints[starter_pos] = composition
                starter_char = composition
                codepoints.delete_at pos
                eoa -= 1
                pos -= 1
                previous_combining_class = -1
              else
                previous_combining_class = current.combining_class
              end
            else
              previous_combining_class = current.combining_class
            end
            if current.combining_class == 0
              starter_pos = pos
              starter_char = codepoints[pos]
            end
          end
        end
        codepoints
      end
       
      def perform_normalization(type, str)
        # See http://www.unicode.org/reports/tr15, Table 1
        codepoints = str.unpack('U*')
        case type
          when :d
            reorder_characters(decompose_codepoints(:canonical, codepoints))
          when :c
            compose_codepoints reorder_characters(decompose_codepoints(:canonical, codepoints))
          when :kd
            reorder_characters(decompose_codepoints(:compatability, codepoints))
          when :kc
            compose_codepoints reorder_characters(decompose_codepoints(:compatability, codepoints))
          else
            raise ArgumentError, "#{type.to_s.upcase} is not a valid normalization variant", caller
        end.pack('U*')
      end
    end
  end
end
