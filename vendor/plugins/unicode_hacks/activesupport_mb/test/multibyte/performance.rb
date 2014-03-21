#!/usr/bin/env ruby

$KCODE = 'u'

$:.unshift("#{File.dirname(__FILE__)}/../../lib")
%w(rubygems benchmark open-uri active_support active_support/multibyte).each { |l| require l }

PARTS = [10, 200, 500, 1000, 2000, 5000, 10000, 20000, 30000, 40000, 50000, 60000]

class PerformanceTest

  HANDLERS = [
    [:UTF8HandlerIcu,        'active_support/multibyte/handlers/utf8_handler_icu'],
    [:UTF8HandlerProc,       'active_support/multibyte/handlers/utf8_handler_proc'],
    [:UTF8HandlerUnicodeExt, 'active_support/multibyte/handlers/utf8_handler_unicode_ext'],
    [:UTF8HandlerPure,       'active_support/multibyte/handlers/utf8_handler_pure'],
    [:UTF8HandlerPure2,      'active_support/multibyte/handlers/utf8_handler_pure2']
  ]

  def initialize
    download_corpus
    load_corpus
    create_parts
  end
   
  def run
    puts "Starting #{self.class.name}"
    HANDLERS.each do |name, lib|
      @handler = ::ActiveSupport::Multibyte::Handlers::const_get name.to_s
      begin
        puts "\n#{@handler.name}"
        Benchmark.benchmark(" "*24 + Benchmark::CAPTION, 24, Benchmark::FMTSTR, 'TOTAL:') do |bm|
          total = Benchmark::Tms.new
          test_methods = methods.delete_if { |m| m !~ /^test_/ }.sort
          test_methods.each do |test_method|
            total += bm.report "#{test_method}:" do
              send test_method.intern
            end
          end
          [total]
        end
      rescue NameError => e
        puts "Skipping #{@handler.name} (#{e})"
      end
    end
  end
  
  def load_corpus
    @corpus = []
    Dir.glob(File.join(File.dirname(__FILE__), 'corpus', '*.txt')).each do |filename|
      @corpus << File.read(filename)
    end
  end

  def download_corpus
    dirname = File.dirname(__FILE__) + '/corpus/'
    File.open(dirname + 'INDEX') do |index|
      index.each_line do |line|
        name = line.split('/')[-1].strip
        unless File.exist?(dirname + name)
          $stderr.puts "Downloading #{line.strip}"
          open(line.strip) do |source|
            File.open(dirname + name, 'w') do |target|
              source.each_line do |sline|
                target.write(sline)
              end
            end
          end
        end
      end
    end
  end
  
  def create_parts
    @parts = {}
    PARTS.each do |length|
      @parts[length] = @corpus[0].unpack('U*')[0..length].pack('U*')
    end
  end
end

class NormalizationTest < PerformanceTest

  [:c, :kc, :d, :kd].each do |variant|
    define_method "test_normalize_#{variant}" do
      @corpus.each do |doc|
        @handler.send "normalize_#{variant.to_s.upcase}".intern, doc #[0..19017]
      end
    end
  end
end

class NormalizationLengthTest < PerformanceTest
  
  PARTS.each do |length|
    define_method "test_normalize_kc_#{length}" do
      @handler.normalize_KC @parts[length]
    end
  end
end

class CaseTest < PerformanceTest
  
  [:upcase, :downcase].each do |variant|
    define_method "test_#{variant}" do
      @corpus.each do |doc|
        @handler.send variant, doc
      end
    end
  end
end

if __FILE__ == $0
  ::ObjectSpace.each_object(Class) do |klass|
    if PerformanceTest > klass
      instance = klass.new
      instance.run
    end
  end 
end
