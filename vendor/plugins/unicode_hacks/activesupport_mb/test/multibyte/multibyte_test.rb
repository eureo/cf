$:.unshift File.dirname(__FILE__) + '/../../lib/'
$KCODE = 'UTF8' # so that the test suite is properly parsed
require 'test/unit'

unless respond_to?(:require_library_or_gem)
  def require_library_or_gem(req)
    begin
      require req
    rescue LoadError
      require 'rubygems'
      require req
    end
  end
end

require_library_or_gem 'active_support'
require 'active_support/multibyte'

class MultibyteTest < Test::Unit::TestCase

  def setup
    # This is an ASCII string with some russian strings and a ligature. It's nicely calibrated, because
    # slicing it at some specific bytes will kill your characters if you use standard Ruby routines.
    # Besides it has both capital and standard letters, so that we can test case conversions easily.
    # It's length is 26 normally and 28 when the ligature gets split during normalization. You
    # have to split ligatures in 99 percent of the cases for purposes like searching, validating length etc...
    @string = "Flup Блå ﬃ бла бла бла бла" # Very Unicode
    @string_kd = "Flup Блå ffi бла бла бла бла" # KD decomp
    @string_kc = "Flup Блå ffi бла бла бла бла" # KC comp
    @string_c = "Flup Блå ﬃ бла бла бла бла" # C comp
    @string_d = "Flup Блå ﬃ бла бла бла бла" # D comp
    @string_kd = "Flup Блå ffi бла бла бла бла" # KD comp
    @bytestring = "\270\236\010\210\245" # Even not UTF-8
    @character_from_class = {
      :l => 0x1100, :v => 0x1160, :t => 0x11A8, :lv => 0xAC00, :lvt => 0xAC01, :cr => 0x000D, :lf => 0x000A,
      :extend => 0x094D, :n => 0x64
    }
  end
  
  def test_a_chars
    assert @string.respond_to?(:chars)
    assert @string.respond_to?(:u)

    assert_kind_of ActiveSupport::Multibyte::Chars, @string.chars
# conflicts with ICU4R, lets pass for now
#    assert_kind_of ActiveSupport::Multibyte::Chars, @string.u

    assert @string.chars.respond_to?(:to_s)
  end
  
  def test_a_identity
    
    assert_equal @string, @string.chars.to_s, "Chars#to_s should bypass to String"
    assert_equal @bytestring, @bytestring.chars.to_s, "Chars#to_s should bypass to String"
    
    assert_nothing_raised do
      assert_equal "a", "a", "Proper string comparisons should be unaffected"
      assert_not_equal "a", "b", "Proper string comparisons should be unaffected"
      assert_not_equal "a".chars, "b".chars
      assert_equal "a".chars, "A".downcase.chars, "Chars objects should be comparable to each other"
      assert_equal "a".chars, "A".downcase, "Chars objects should be comparable to strings coming from elsewhere"
    end

    assert_equal "a", "a", "Proper string comparisons should be unaffected"
    assert_not_equal "a", "b", "Proper string comparisons should be unaffected"
    
    assert !@string.eql?(@string.chars), "Strict comparison is not supported"
    assert_equal @string, @string.chars, "Chars should be comparable with their bearing strings"

    other_string = @string.dup
    assert_equal other_string, @string.chars, "Chars should be comparable with their bearing strings"
    assert_equal other_string.chars, @string.chars, "Chars should be comparable with each other based on the contents"
    
    strings = ['builder'.chars, 'armor'.chars, 'zebra'.chars]
    
    strings.sort!

    assert_equal ['armor', 'builder', 'zebra'], strings, "Chars should be sortable based on contents"

    # This leads to a StackLevelTooDeep exception if the comnparison is not wired properly
    assert_raise(NameError) do
      Chars
    end
  end
  
  def test_method_chaining
    
    assert_kind_of ActiveSupport::Multibyte::Chars, 'foo'.chars.downcase
    assert_kind_of ActiveSupport::Multibyte::Chars, "  FOO   ".chars.strip, "Strip should return a Chars object"
    assert_kind_of ActiveSupport::Multibyte::Chars, "  FOO   ".chars.downcase.strip, "The Chars object should be " +
        "forwarded down the call path for chaining"

    assert_equal 'foo', "  FOO   ".chars.normalize.downcase.strip, "The Chars that results from the " +
      " operations should be comparable to the string value of the result"
  end
  
  def test_normalize
    assert @bytestring.respond_to?(:chars)
    assert @bytestring.respond_to?(:u)
    
    assert_equal @string_d, @string.chars.decompose
    
    with_kcode('none') do
      assert_raise(NoMethodError) { @string.chars.decompose }
    end
    
    assert_equal @string_kc, @string.chars.normalize
    
    normalized = @string.chars.normalize.to_s    
    @string.chars.normalize!
    assert_equal normalized, @string
  end

  def test_a_semantics
    assert ActiveSupport::Multibyte::Handlers::UTF8Handler.consumes?(@string), "This is a valid UTF-8 string"
    assert !ActiveSupport::Multibyte::Handlers::UTF8Handler.consumes?(@bytestring), "This is bytestring"

    assert !@bytestring.is_utf8?, "This is a bytestring"
    assert @string.is_utf8?, "This is a valid UTF-8 string"
  end
  
  def test_size
    assert_equal 26, @string.chars.size, "String length should be 26"
    assert_equal 26, @string.chars.length, "String length method should be properly aliased"
    
    assert_equal 43, @string.size, "String#size should still count bytes"
    
    with_kcode('none') do
      assert_equal 43, @string.chars.size,
        "String length should be 43 because we are out of the UTF8 KCODE"
    end
    
    assert_equal 5, @bytestring.size
    assert_equal 5, @bytestring.chars.size
  end

  # Test g_length of the pure2 handler, this should merge with length testing in the future
  def test_g_length
    if ActiveSupport::Multibyte::Handlers::UTF8HandlerPure2 == ''.chars.send(:handler)
      assert_equal 0, ''.chars.g_length, "String should count 0 grapheme clusters"
      assert_equal 2, [0x0924, 0x094D, 0x0930].pack('U*').chars.g_length, "String should count 2 grapheme clusters"
      assert_equal 1, string_from_classes(%w(cr lf)).chars.g_length, "Don't cut between CR and LF"
      assert_equal 1, string_from_classes(%w(l l)).chars.g_length, "Don't cut between L"
      assert_equal 1, string_from_classes(%w(l v)).chars.g_length, "Don't cut between L and V"
      assert_equal 1, string_from_classes(%w(l lv)).chars.g_length, "Don't cut between L and LV"
      assert_equal 1, string_from_classes(%w(l lvt)).chars.g_length, "Don't cut between L and LVT"
      assert_equal 1, string_from_classes(%w(lv v)).chars.g_length, "Don't cut between LV and V"
      assert_equal 1, string_from_classes(%w(lv t)).chars.g_length, "Don't cut between LV and T"
      assert_equal 1, string_from_classes(%w(v v)).chars.g_length, "Don't cut between V and V"
      assert_equal 1, string_from_classes(%w(v t)).chars.g_length, "Don't cut between V and T"
      assert_equal 1, string_from_classes(%w(lvt t)).chars.g_length, "Don't cut between LVT and T"
      assert_equal 1, string_from_classes(%w(t t)).chars.g_length, "Don't cut between T and T"
      assert_equal 1, string_from_classes(%w(n extend)).chars.g_length, "Don't cut before Extend"
      assert_equal 2, string_from_classes(%w(n n)).chars.g_length, "Cut between normal characters"
      assert_equal 3, string_from_classes(%w(n cr lf n)).chars.g_length, "Don't cut between CR and LF"
      assert_equal 2, string_from_classes(%w(n l v t)).chars.g_length, "Don't cut between L, V and T"
    end
  end
  
  def test_matching_and_position
    with_kcode('none') do
      assert_equal 3, ("we are the world".chars =~ /are the world/),
        "Regex matching should be bypassed to String"
    end
    
    str = "Блå" # all double-width
    
    with_kcode('u') do
      assert_equal 0, str.chars.translate_offset(0), "First character, first byte"
      assert_equal 0, str.chars.translate_offset(1), "First character, second byte"
      assert_equal 1, str.chars.translate_offset(2), "Second character, third byte"
      assert_equal 1, str.chars.translate_offset(3), "Second character, fourth byte"
      assert_equal 2, str.chars.translate_offset(4), "Third character, fifth byte"
      assert_equal 2, str.chars.translate_offset(5), "Third character, sixth byte"

      assert_equal 2, (str.chars =~ /å/), "Regex matching should should return offset in chars"
      assert_equal 1, (str.chars =~ /л/), "Regex matching should should return offset in chars"
      assert_nil (str.chars =~ /ß/), "Non-match should return nil"
    end
    
    with_kcode('none') do
      assert_equal 0, str.chars.translate_offset(0), "First byte"
      assert_equal 1, str.chars.translate_offset(1), "Second byte"
      assert_equal 2, str.chars.translate_offset(2), "Third byte"
      assert_equal 3, str.chars.translate_offset(3), "Fourth byte"
      assert_equal 4, str.chars.translate_offset(4), "Fifth byte"
      assert_equal 5, str.chars.translate_offset(5), "Sixth byte"

      assert_equal 4, (str.chars =~ /å/), "Regex matching should count bytes"
      assert_equal 2, (str.chars =~ /л/), "Regex matching should return offset in byes"
      assert_nil (str.chars =~ /ß/), "Non-match should return nil"
    end
  end
    
  def test_slice
    assert_equal "p Блå ﬃ", @string.chars[3..9], "Unicode characters have to be returned"
    assert_equal "p Блå ﬃ", @string.chars.slice(3..9), "Slice should be properly aliased"
    assert_equal "\270\236\010\210", @bytestring.chars[0..3], "Bytes should be returned from a string that is not a UTF-8 sequence"
  end
  
  def test_split
    word = "eﬃcient"
    chars = ["e", "ﬃ", "c", "i", "e", "n", "t"]

    assert_equal chars, word.split(//)
    assert_equal chars, word.chars.split(//)
    assert_kind_of ActiveSupport::Multibyte::Chars, word.chars.split(//).first
  end
  
  def test_insert
    assert_equal "\270\236\210\010\210\245", @bytestring.chars.insert(2, "\210")
    assert_equal "\270\236\210\010\210\245", @bytestring
    
    setup # insert is destructive!
    assert_equal "Flup Блå ﬃБУМ бла бла бла бла", @string.chars.insert(10, "БУМ"), "Text should be inserted at right codepoints"
    assert_equal "Flup Блå ﬃБУМ бла бла бла бла", @string, "Chars#insert should be destructive for the string"
  end
  
  def test_reverse
    assert_equal "алб алб алб алб ﬃ åлБ pulF", @string.chars.reverse,
        
    s = "Καλημέρα κόσμε!"
    reversed = "!εμσόκ αρέμηλαΚ"
    assert_equal reversed, s.chars.reverse
    
    assert_equal "\245\210\010\236\270", @bytestring.reverse, "Standard reverse should work"
    assert_equal "\245\210\010\236\270", @bytestring.chars.reverse, "Bytes should be reversed"
    
    @bytestring.chars.reverse!
    assert_equal "\245\210\010\236\270", @bytestring, "Bytes should be reversed with bang!"
  end
    
  def test_index
     # String#index isn't Unicode-aware, it's counting bytes
     s = "Καλημέρα κόσμε!" 
     assert_equal 0, s.chars.index('Κ'), "Greek K is at 0"
     assert_equal 1, s.chars.index('α'), "Greek Alpha is at 1"
  end

  def test_pragma
    assert " ".chars.send(:utf8_pragma?), "UTF8 pragma should be on because KCODE is UTF8"

    with_kcode('none') do
      assert !" ".chars.send(:utf8_pragma?), "UTF8 pragma should off"
    end
  end
    
  def test_whitespaces
    # This is Unicode whitespace. Well, 5 different kinds of it to be precise, including the NO BREAK SPACE
    # also known as the BOM
    # With a "U" in the middle. When strip'ped, only the "U" should remain
    @string = "\n" + [
      32, # SPACE
      8195, # EM SPACE
      8199, # FIGURE SPACE,
      8201, # THIN SPACE
      8202, # HAIR SPACE
      65279, # NO BREAK SPACE (ZW)
      "some блин\n\n\n  text".unpack("U*"),
      65279, # NO BREAK SPACE (ZW)
      8201, # THIN SPACE
      8199, # FIGURE SPACE,      
      32, # SPACE
    ].flatten.pack("U*")
    
    lstripped = [
      "some блин\n\n\n  text".unpack("U*"), 
      65279, # NO BREAK SPACE (ZW)
      8201, # THIN SPACE
      8199, # FIGURE SPACE,      
      32, # SPACE
    ].flatten.pack("U*")

    rstripped = "\n" + [
      32, # SPACE
      8195, # EM SPACE
      8199, # FIGURE SPACE,
      8201, # THIN SPACE
      8202, # HAIR SPACE
      65279, # NO BREAK SPACE (ZW)
      "some блин\n\n\n  text".unpack("U*"), 
    ].flatten.pack("U*")

    assert_equal lstripped, @string.chars.lstrip, "Unicode space should be stripped to the left of U"
    assert_equal rstripped, @string.chars.rstrip, "Unicode space should be stripped to the right of U"
    assert_equal "some блин\n\n\n  text", @string.chars.strip, "Unicode space should be stripped"

    @string.chars.strip!
    assert_equal "some блин\n\n\n  text", @string, "Chars#strip! should be destructive for the bearing String"
    
    bs = "\n   #{@bytestring} \n\n"
    assert_equal @bytestring, bs.strip, "Chars#strip! should be destructive for the bearing String"
  
    with_kcode('none') do
      str = "\n\nSome text\n\n\nand more\n   \n"
      assert_equal "Some text\n\n\nand more", str.chars.strip,
        "Whitespaces in the middle should be preserved"
    end

    str = "\n\nSome text\n\n\nand more\n   \n"
    assert_equal "Some text\n\n\nand more", ActiveSupport::Multibyte::Handlers::UTF8Handler.strip(str),
      "Whitespaces in the middle should be preserved"
  end
  
  def test_pragma
    assert " ".chars.send(:utf8_pragma?), "UTF8 pragma should be on because KCODE is UTF8"

    with_kcode('none') do
      assert !" ".chars.send(:utf8_pragma?), "UTF8 pragma should be off"
    end
  end
  
  def test_empties_and_gsub
    str = ' '
    assert_equal '', str.chars.downcase.strip
    assert_equal '', str.downcase.strip
    assert_equal '', str.chars.upcase.strip
    assert_equal '', str.chars.strip[0..345]
    
    str = ''
    assert_equal '', str.chars.downcase.strip
    assert_equal '', str.downcase.strip
    
    assert_equal 'axa', 'ada'.chars.gsub(/d/, 'x')

    with_kcode('none') do
      assert_equal 'axa', 'ada'.chars.gsub(/d/, 'x')
    end
  end
  
  def test_upcase
    with_kcode('none') do
      initial = @string.dup
      assert_equal initial.upcase, @string.chars.upcase, "Normal upcase should be used"

      @string.chars.upcase!
      assert_equal initial.upcase, @string,  "Normal upcase should be used"
    end

    assert_equal "FLUP БЛÅ FFI БЛА БЛА БЛА БЛА", @string.chars.upcase, "Ligature has to be decomposed after upcase"

    @string.chars.upcase!
    assert_equal "FLUP БЛÅ FFI БЛА БЛА БЛА БЛА", @string

  end
  
  def test_downcase
    with_kcode('none') do
      initial = @string.dup
      assert_equal initial.downcase, @string.chars.downcase, "Normal downcase should be used"

      @string.chars.downcase!
      assert_equal initial.downcase, @string,  "Normal downcase should be used"
    end

    assert_equal "flup блå ﬃ бла бла бла бла", @string.chars.downcase
    @string.chars.downcase!
    assert_equal "flup блå ﬃ бла бла бла бла", @string    
  end
  
  private

    def with_kcode(kcode)
      old_kc, $KCODE = $KCODE, kcode
      begin
        yield
      ensure
        $KCODE = old_kc
      end
    end

    def string_from_classes(classes)
      classes.collect do |k|
        @character_from_class[k.intern]        
      end.pack('U*')
    end
end
