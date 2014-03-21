$:.unshift File.dirname(__FILE__) + '/../../lib'
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

UNIDATA_VERSION = "4.1.0"
UNIDATA_URL = "http://www.unicode.org/Public/#{UNIDATA_VERSION}/ucd/"

normalization_test_f = File.dirname(__FILE__) + '/NormalizationTest.txt'
unless File.exist?(normalization_test_f)
  require 'open-uri'
  open("#{UNIDATA_URL}/NormalizationTest.txt") do | resp |
    $stderr.puts "Downloading normalization test suite from Unicode Consortium, Unicode version #{UNIDATA_VERSION}"
    File.open(normalization_test_f, 'w') do | f |
      until resp.eof?
        f << resp.read(4056)
      end
    end
  end
end

class String
  def u_inspect
    "#{self} " + ("[%s]" % unpack("U*").map{|cp| cp.to_s(16) }.join(' '))
  end
  
  alias_method :ui, :u_inspect
end

unless ENV['AS_MULTIBYTE_SKIP_HANDLING_TESTS']
module UTF8HandlingTests
  
  def common_setup
    @string = "Flup Блå ﬃ бла бла бла бла" # Very Unicode
    @string_kd = "Flup Блå ffi бла бла бла бла" # KD decomp
    @string_kc = "Flup Блå ffi бла бла бла бла" # KC comp
    @string_c = "Flup Блå ﬃ бла бла бла бла" # C comp
    @string_d = "Flup Блå ﬃ бла бла бла бла" # D comp
    @string_kd = "Flup Блå ffi бла бла бла бла" # KD comp
  end
  
  def test_simple_normalization
    null_byte_str = "Test\0test" 

    assert_equal null_byte_str.ui, @handler.normalize_KC(null_byte_str).ui, "Null byte should remain" 
    assert_equal null_byte_str.ui, @handler.normalize_C(null_byte_str).ui, "Null byte should remain" 
    assert_equal null_byte_str.ui, @handler.normalize_D(null_byte_str).ui, "Null byte should remain"
    assert_equal null_byte_str.ui, @handler.decompose(null_byte_str).ui, "Null byte should remain" 
    
    comp_str = [
      44,  # LATIN CAPITAL LETTER D
      307, # COMBINING DOT ABOVE
      328, # COMBINING OGONEK
      323, # COMBINING DOT BELOW
    ].pack("U*")
    
    norm_str_KC = [
      44,
      105,
      106,
      328,
      323,
    ].pack("U*")
    
    norm_str_C = [
      44,
      307,
      328,
      323,
    ].pack("U*")
    
    norm_str_D = [
      44,
      307,
      110,
      780,
      78,
      769,
    ].pack("U*")
    
    norm_str_KD = [
      44,
      105,
      106,
      110,
      780,
      78,
      769,
    ].pack("U*")
    
    # Here we use the output of ICU4R as reference, it's a golden standard alas
    assert_equal norm_str_KC.ui, @handler.normalize_KC(comp_str).ui, "Should normalize KC"
    assert_equal norm_str_C.ui, @handler.normalize_C(comp_str).ui, "Should normalize C"
    assert_equal norm_str_D.ui, @handler.normalize_D(comp_str).ui, "Should normalize D"
    assert_equal norm_str_KD.ui, @handler.normalize_KD(comp_str).ui, "Should normalize KD"
  end
  
  def test_normalization_C_pri_29
    [
      [0x0B47, 0x0300, 0x0B3E],
      [0x1100, 0x0300, 0x1161]
    ].map { |c| c.pack('U*') }.each do |c|
      assert_equal c.ui, @handler.normalize_C(c).ui
    end
  end
  
  def test_normalizations_C
    each_line_of_norm_tests do |*cols|
      col1, col2, col3, col4, col5, comment = *cols

      # CONFORMANCE:
      # 1. The following invariants must be true for all conformant implementations
      #
      #    NFC
      #      c2 ==  NFC(c1) ==  NFC(c2) ==  NFC(c3)
      assert_equal col2.ui, @handler.normalize_C(col1).ui, "Form C - Col 2 has to be NFC(1) - #{cols.inspect}"
      assert_equal col2.ui, @handler.normalize_C(col2).ui, "Form C - Col 2 has to be NFC(2) - #{cols.inspect}"
      assert_equal col2.ui, @handler.normalize_C(col3).ui, "Form C - Col 2 has to be NFC(3) - #{cols.inspect}"
      #
      #      c4 ==  NFC(c4) ==  NFC(c5)
      assert_equal col4.ui, @handler.normalize_C(col4).ui, "Form C - Col 4 has to be C(4) - #{cols.inspect}"
      assert_equal col4.ui, @handler.normalize_C(col5).ui, "Form C - Col 4 has to be C(5) - #{cols.inspect}"
    end
  end
  
  def test_normalizations_D
    each_line_of_norm_tests do |*cols|
      col1, col2, col3, col4, col5, comment = *cols
      #
      #    NFD
      #      c3 ==  NFD(c1) ==  NFD(c2) ==  NFD(c3)
      assert_equal col3.ui, @handler.normalize_D(col1).ui, "Form D - Col 3 has to be NFD(1) - #{cols.inspect}"
      assert_equal col3.ui, @handler.normalize_D(col2).ui, "Form D - Col 3 has to be NFD(2) - #{cols.inspect}"
      assert_equal col3.ui, @handler.normalize_D(col3).ui, "Form D - Col 3 has to be NFD(3) - #{cols.inspect}"
      #      c5 ==  NFD(c4) ==  NFD(c5)
      assert_equal col5.ui, @handler.normalize_D(col4).ui, "Form D - Col 5 has to be NFD(4) - #{cols.inspect}"
      assert_equal col5.ui, @handler.normalize_D(col5).ui, "Form D - Col 5 has to be NFD(5) - #{cols.inspect}"
    end
  end

  def test_normalizations_KC
    each_line_of_norm_tests do | *cols |
      col1, col2, col3, col4, col5, comment = *cols  
      #
      #    NFKC
      #      c4 == NFKC(c1) == NFKC(c2) == NFKC(c3) == NFKC(c4) == NFKC(c5)
      assert_equal col4.ui, @handler.normalize_KC(col1).ui, "Form D - Col 4 has to be NFKC(1) - #{cols.inspect}"
      assert_equal col4.ui, @handler.normalize_KC(col2).ui, "Form D - Col 4 has to be NFKC(2) - #{cols.inspect}"
      assert_equal col4.ui, @handler.normalize_KC(col3).ui, "Form D - Col 4 has to be NFKC(3) - #{cols.inspect}"
      assert_equal col4.ui, @handler.normalize_KC(col4).ui, "Form D - Col 4 has to be NFKC(4) - #{cols.inspect}"
      assert_equal col4.ui, @handler.normalize_KC(col5).ui, "Form D - Col 4 has to be NFKC(5) - #{cols.inspect}"
    end
  end

  def test_normalizations_KD
    each_line_of_norm_tests do | *cols |
      col1, col2, col3, col4, col5, comment = *cols  
      #
      #    NFKD
      #      c5 == NFKD(c1) == NFKD(c2) == NFKD(c3) == NFKD(c4) == NFKD(c5)
      assert_equal col5.ui, @handler.normalize_KD(col1).ui, "Form KD - Col 5 has to be NFKD(1) - #{cols.inspect}"
      assert_equal col5.ui, @handler.normalize_KD(col2).ui, "Form KD - Col 5 has to be NFKD(2) - #{cols.inspect}"
      assert_equal col5.ui, @handler.normalize_KD(col3).ui, "Form KD - Col 5 has to be NFKD(3) - #{cols.inspect}"
      assert_equal col5.ui, @handler.normalize_KD(col4).ui, "Form KD - Col 5 has to be NFKD(4) - #{cols.inspect}"
      assert_equal col5.ui, @handler.normalize_KD(col5).ui, "Form KD - Col 5 has to be NFKD(5) - #{cols.inspect}"
    end
  end  
  
  def test_casefolding
    simple_str = "abCdef"
    simple_str_upcase = "ABCDEF"
    simple_str_downcase = "abcdef"

    assert_equal simple_str_upcase, @handler.upcase(simple_str), "should upcase properly"
    assert_equal simple_str_downcase, @handler.downcase(simple_str), "should downcase properly"
    
    rus_str = "аБвгд\0f"
    rus_str_upcase = "АБВГД\0F"
    rus_str_downcase = "абвгд\0f"    

    assert_equal rus_str_upcase, @handler.upcase(rus_str), "should upcase properly honoring null-byte"
    assert_equal rus_str_downcase, @handler.downcase(rus_str), "should downcase properly honoring null-byte"
  end
  
  def test_offset
    str = "Блå" # all double-width
    
    assert_equal 0, @handler.translate_offset(str, 0), "First character, first byte"
    assert_equal 0, @handler.translate_offset(str, 1), "First character, second byte"
    assert_equal 1, @handler.translate_offset(str, 2), "Second character, third byte"
    assert_equal 1, @handler.translate_offset(str, 3), "Second character, fourth byte"
    assert_equal 2, @handler.translate_offset(str, 4), "Third character, fifth byte"
    assert_equal 2, @handler.translate_offset(str, 5), "Third character, sixth byte"    
  end
  
  def test_insert
    assert_equal "Flup Блå ﬃБУМ бла бла бла бла", @handler.insert(@string, 10, "БУМ"), 
      "Text should be inserted at right codepoints"
  end
  
  def test_reverse
    str = "wБлå" # all double-width
    rev = "åлБw" # all double-width
    assert_equal rev.ui, @handler.reverse(str).ui, "Should reverse properly"
  end

  def test_size
    str = "wБлå" # all double-width
    assert_equal 4, @handler.size(str)    
  end
  
  def test_slice
    assert_equal "p Блå ﬃ", @handler.slice(@string, 3..9), "Unicode characters have to be returned"
  end

  private
    def each_line_of_norm_tests(&block)
      unless File.exist?(File.dirname(__FILE__) + '/NormalizationTest.txt')
        flunk "Please download the test cases from http://www.unicode.org/Public/UNIDATA/NormalizationTest.txt" and return
      end
      
      lines = 0
      max_test_lines = 0 # Don't limit below 38, because that's the header of the testfile
      File.open(File.dirname(__FILE__) + '/NormalizationTest.txt', 'r') do | f |
        until f.eof? || (max_test_lines > 0 and lines > max_test_lines)
          lines += 1
          line = f.gets
          line.chomp!
          next if (line.empty? || line =~ /^\#/)      

          cols, comment = line.split("#")
          cols = cols.split(";").map{|e| e.strip}.reject{|e| e.empty? }
          next unless cols.length == 5

          # codepoints are in hex in the test suite
          cols.map!{|c| c.split.map{|codepoint| codepoint.to_i(16)}.pack("U*") }
          cols << comment

          yield(*cols)
        end
      end
    end
end

$backends = []

# Load different backends nevertheless
def with_external_dependency(*libs, &suite)
  begin
    libs.map{ | lib |  require_library_or_gem(lib) }
    yield
  rescue LoadError
  end
end

$mbdir = File.expand_path(File.dirname(__FILE__) + '/../../lib/active_support/multibyte')

with_external_dependency('icu4r') do
  require $mbdir + '/handlers/utf8_handler_icu'
  $backends << "ICU4R"
  class ICUTest < Test::Unit::TestCase
    include UTF8HandlingTests
    def setup
      common_setup
      @handler = ::ActiveSupport::Multibyte::Handlers::UTF8HandlerIcu
    end
  end
end

with_external_dependency('utf8proc_native') do
  require $mbdir + '/handlers/utf8_handler_proc'
  $backends << "utf8_proc"
  class Utf8ProcTest < Test::Unit::TestCase
    include UTF8HandlingTests
    def setup
      common_setup
      @handler = ::ActiveSupport::Multibyte::Handlers::UTF8HandlerProc
    end
  end
end

with_external_dependency('unicode') do
  require $mbdir + '/handlers/utf8_handler_unicode_ext'
  $backends << "Unicode gem"
  class UnicodeGemTest < Test::Unit::TestCase
    include UTF8HandlingTests
    def setup
      common_setup
      @handler = ::ActiveSupport::Multibyte::Handlers::UTF8HandlerUnicodeExt
    end
  end
end

with_external_dependency($mbdir + '/handlers/utf8_handler_pure_tables', $mbdir + '/handlers/utf8_handler_pure') do
  class PureTest < Test::Unit::TestCase
    $backends << "utf8_proc in Ruby"
    include UTF8HandlingTests
    def setup
      common_setup
      @handler = ::ActiveSupport::Multibyte::Handlers::UTF8HandlerPure
    end
  end
end

class Pure2Test < Test::Unit::TestCase
  $backends << "pure Ruby"
  include UTF8HandlingTests
  def setup
    common_setup
    @handler = ::ActiveSupport::Multibyte::Handlers::UTF8HandlerPure2
  end
end

$stderr.puts "Testing #{$backends.to_sentence} unicode backends"
else
  $stderr.puts "Skipping Unicode handling tests"
end