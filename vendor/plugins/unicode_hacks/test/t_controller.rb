require File.dirname(__FILE__) + '/test_helper'
$KCODE = 'u'

class NormalizingController < ActionController::Base
  self.template_root = File.dirname(__FILE__) + '/random'
  
  def xml_action
    render 'xml.rxml'
  end
  
  def rjs
    render :update => 'page' do | pg |
    end
  end
  
  def inline
    render 'templ.rhtml'
  end
end

class ControllerUnicodeTest < Test::Unit::TestCase

  def setup
    @controller = NormalizingController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  # Make sure the correct Content-Type headers are returned with various render variants
  [[lambda { |ctlr| ctlr.get :inline }, 'text/html; charset=UTF-8'],
    [lambda { |ctlr| ctlr.xhr :get, :rjs }, 'text/javascript; charset=UTF-8'],
    [lambda { |ctlr| ctlr.get :xml_action }, 'application/xml; charset=UTF-8']].each do |variant, content_type|
    define_method "test_a_header_overridden_#{content_type.split(';').first.gsub('/', '_')}" do
      with_kcode('u') do
        variant.call(self)
        assert_success      
        assert_equal content_type, @response.headers["Content-Type"]
      end
    end
  end
  
  private
    def with_kcode(kcode)
      old_kc = $KCODE
      begin
        $KCODE = kcode
        yield
      ensure
        $KCODE = old_kc
      end
    end
end