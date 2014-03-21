# Dumbly ported libutf8proc to Ruby.
require File.dirname(__FILE__) + '/utf8_handler_pure_tables' # Not clear how they bake them though
class ActiveSupport::Multibyte::Handlers::UTF8HandlerPure < ActiveSupport::Multibyte::Handlers::UTF8Handler
 UTF8PROC_STABLE   =(1<<1)
 UTF8PROC_COMPAT   =(1<<2)
 UTF8PROC_COMPOSE  =(1<<3)


 UTF8PROC_HANGUL_SBASE = 0xAC00
 UTF8PROC_HANGUL_LBASE = 0x1100
 UTF8PROC_HANGUL_VBASE = 0x1161
 UTF8PROC_HANGUL_TBASE = 0x11A7
 UTF8PROC_HANGUL_LCOUNT = 19
 UTF8PROC_HANGUL_VCOUNT = 21
 UTF8PROC_HANGUL_TCOUNT = 28
 UTF8PROC_HANGUL_NCOUNT = 588
 UTF8PROC_HANGUL_SCOUNT = 11172
=begin
typedef struct utf8proc_property_struct {
0    char    *category;
1    int16_t  combining_class;
2    char    *bidi_class;
3    char    *decomp_type;
4    int32_t *decomp_mapping;
5    unsigned bidi_mirrored:1;
6    int32_t  uppercase_mapping;
7    int32_t  lowercase_mapping;
8    int32_t  titlecase_mapping;
9    int32_t  comb1st_index;
10   int32_t  comb2nd_index;
11   unsigned comp_exclusion:1;
12   unsigned ignorable:1;
13   int32_t  *casefold_mapping;
} utf8proc_property_t;
=end
class << self
  private # whale guts
  
  def category(property); property[0]; end
  def combining_class(property); property[1]; end
  def bidi_class(property); property[2]; end
  def decomp_type(property); property[3]; end
  def decomp_mapping(property); property[4]; end
  def bidi_mirrored(property); property[5]; end
  def uppercase_mapping(property); property[6]; end
  def lowercase_mapping(property); property[7]; end
  def titlecase_mapping(property); property[8]; end
  def comb1st_index(property); property[9]; end
  def comb2nd_index(property); property[10]; end
  def comp_exclusion(property); property[11]; end
  def ignorable(property); property[12]; end
  def casefold_mapping(property); property[13]; end

   def decomp_mapping_each(property, &block) 
     idx = decomp_mapping(property)
     while Utf8proc_sequences[idx] >= 0
       yield Utf8proc_sequences[idx]
       idx += 1
     end
   end

   def utf8proc_get_property(uc) 
       return Utf8proc_properties[ Utf8proc_stage2table[ Utf8proc_stage1table[uc >> 8] + (uc & 0xFF) ] ]
   end


  def utf8proc_decompose_char( uc, dst, options) 
    property = utf8proc_get_property(uc)
    hangul_sindex = uc - UTF8PROC_HANGUL_SBASE
    if (hangul_sindex >= 0 && hangul_sindex < UTF8PROC_HANGUL_SCOUNT) 
      dst << (UTF8PROC_HANGUL_LBASE + hangul_sindex / UTF8PROC_HANGUL_NCOUNT)
      dst << (UTF8PROC_HANGUL_VBASE + (hangul_sindex % UTF8PROC_HANGUL_NCOUNT) / UTF8PROC_HANGUL_TCOUNT)
      hangul_tindex = hangul_sindex % UTF8PROC_HANGUL_TCOUNT
      return if hangul_tindex == 0
      dst << (UTF8PROC_HANGUL_TBASE + hangul_tindex)
    elsif  (decomp_mapping(property) && (!decomp_type(property) || (options & UTF8PROC_COMPAT)!=0)) 
      decomp_mapping_each(property) { |decomp_entry| utf8proc_decompose_char(decomp_entry, dst, options) }
    else 
      dst << uc
    end
  end

  def utf8proc_decompose(str, buffer,  options) 
    str.each { |uc|  utf8proc_decompose_char( uc, buffer,  options) }
    pos = 0
    wpos = buffer.length-1
    while (pos < wpos ) 
        uc1 = buffer[pos]
        uc2 = buffer[pos+1]
        property1 = utf8proc_get_property(uc1)
        property2 = utf8proc_get_property(uc2)
        if (combining_class(property1) > combining_class(property2) && combining_class(property2) > 0) 
          buffer[pos] = uc2
          buffer[pos+1] = uc1
          pos += pos > 0 ?  -1 :  1
        else
          pos += 1
        end
     end
  end  

  def utf8proc_reencode(buffer, options) 
    wpos = 0
    if (options & UTF8PROC_COMPOSE) != 0
      max_combining_class = -1
      composition = nil
      starter = nil
      starter_property = nil
      current_property = nil
      buffer.each do |current_char|
        current_property = utf8proc_get_property(current_char)
        if (starter && combining_class(current_property) > max_combining_class) 
          # START HANGUL
          hangul_lindex = buffer[starter] - UTF8PROC_HANGUL_LBASE
          if (hangul_lindex >= 0 && hangul_lindex < UTF8PROC_HANGUL_LCOUNT) 
            hangul_vindex = current_char - UTF8PROC_HANGUL_VBASE
            if (hangul_vindex >= 0 && hangul_vindex < UTF8PROC_HANGUL_VCOUNT) 
              buffer[starter] = UTF8PROC_HANGUL_SBASE + (hangul_lindex * UTF8PROC_HANGUL_VCOUNT + hangul_vindex) *  UTF8PROC_HANGUL_TCOUNT
              starter_property = nil
              next
            end
          end
          hangul_sindex = buffer[starter] - UTF8PROC_HANGUL_SBASE
          if (hangul_sindex >= 0 && hangul_sindex < UTF8PROC_HANGUL_SCOUNT &&  (hangul_sindex % UTF8PROC_HANGUL_TCOUNT) == 0) 
            hangul_tindex = current_char - UTF8PROC_HANGUL_TBASE
            if (hangul_tindex >= 0 && hangul_tindex < UTF8PROC_HANGUL_TCOUNT) 
              buffer[starter] += hangul_tindex
              starter_property = nil
              next
            end
          end
          # END HANGUL
          starter_property = utf8proc_get_property(buffer[starter]) unless starter_property
          if (comb1st_index(starter_property) >= 0 &&  comb2nd_index(current_property) >= 0) 
            composition = Utf8proc_combinations[  comb1st_index(starter_property) + comb2nd_index(current_property) ]
            if (composition >= 0 && ( (0 == (options & UTF8PROC_STABLE)) || !comp_exclusion(utf8proc_get_property(composition)) )) 
              buffer[starter] = composition
              starter_property = nil
              next
            end
          end
        end
        buffer[wpos] = current_char
        cur_com_class = combining_class(current_property)
        if  cur_com_class != 0
          if (cur_com_class > max_combining_class) 
            max_combining_class = cur_com_class
          end
        else 
          starter = wpos
          starter_property = nil
          max_combining_class = -1
        end
        wpos += 1
      end
      buffer.slice!( wpos, buffer.size-wpos) if wpos != buffer.size
    end
  end

  def utf8proc_map(str, options) 
    buffer = str.unpack("U*")
    tempbuffer = []
    utf8proc_decompose(buffer, tempbuffer, options)
    utf8proc_reencode(tempbuffer, options)
    tempbuffer.pack("U*")
  end

  public
  
  def normalize_D(str) 
    utf8proc_map(str, UTF8PROC_STABLE)
  end

  def normalize_C(str) 
    utf8proc_map(str, UTF8PROC_STABLE |  UTF8PROC_COMPOSE)
  end

  def normalize_KD(str) 
    utf8proc_map(str, UTF8PROC_STABLE |  UTF8PROC_COMPAT)
  end

  def normalize_KC(str) 
    utf8proc_map(str,  UTF8PROC_STABLE | UTF8PROC_COMPOSE | UTF8PROC_COMPAT)
  end

  alias_method :decompose, :normalize_D

  def upcase(str)
    str.unpack("U*").map do |x| 
       f = uppercase_mapping(utf8proc_get_property(x))
       f >= 0 ? f : x
    end.pack("U*")
  end

  def downcase(str)
    str.unpack("U*").map do |x| 
       f = lowercase_mapping(utf8proc_get_property(x))
       f >= 0 ? f : x
    end.pack("U*")
  end
end
end
