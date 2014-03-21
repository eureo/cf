unless defined?(ActionController)
  hel = File.dirname(__FILE__) + '/../../../test/test_helper'
  require hel
end

require File.dirname(__FILE__) + '/../../lib/action_controller/normalization'
ActionController::Base.send(:include, ActionController::Normalization)
class Test::Unit::TestCase
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

class NormalizingController < ActionController::Base
  normalize_params :form => 'KC'
  
  def rescue_action(e); raise e; end
  
  def post_some_params
    render :text=>params[:foobar][:a]
  end
  
  def call_param
    render :text => params[:texts][:a]
  end
end

class SubController < NormalizingController
end

class NormalizationFilterTest < Test::Unit::TestCase

  def setup
    @controller = NormalizingController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @bytestring = "\270\236\010\210\245" # Even not UTF-8
  end
    
  # Test if the newlines are properly cleaned when KCODE is 'u' and not cleaned otherwise
  [['none',"\n\nSome text\n\n\nand more\n   \n"],['u',"Some text\n\n\nand more"]].each do |kcode, result|
    define_method "test_newlines_properly_cleaned_in_params_#{kcode}" do
      with_kcode(kcode) do
        post :post_some_params, :foobar => { :a => "\n\nSome text\n\n\nand more\n   \n" }
        assert_success
        assert_equal result, @response.body
      end
    end
  end
  
  def test_improper_utf8_sequence_passed_verbatim
    with_kcode('u') do
      assert_nothing_raised do
        params = {:texts=>{:a => @bytestring}}
        post :call_param, params
        assert_success
        assert_equal @bytestring, @response.body
      end
    end
  end
  
  # Test if normalization to KC is performed when KCODE is 'u' and not cleaned otherwise
  [['none', "flup блå ﬃ"], ['u', "flup блå ffi"]].each do |kcode, result|
    define_method "test_params_normalized_to_KC_#{kcode}" do
      with_kcode(kcode) do
        post :call_param, :texts => {:a => "flup блå ﬃ"}
        assert_success
        assert_equal result, @response.body
      end
    end
  end
  
  def test_array_passed_verbatim
    post :call_param, :texts => {:a => "flup блå ﬃ"}, :items => [1,2,3]
    assert_success
    assert_equal [1,2,3], @controller.params[:items]
  end
  
  def test_controller_setup
    assert_nothing_raised { NormalizingController.send(:normalize_params) }
  
    assert_raise(ActionController::Normalization::UnknownNormalizationOptions) do
      NormalizingController.send(:normalize_params, :form => 'AZ')
    end
    
    assert_nothing_raised do
      NormalizingController.send(:normalize_params, :form => 'C')
    end
  end
  
  def test_filter_definition_overridden

    normal_text = 'блå ﬃ'
    kc_normalized = 'блå ffi'
    
    NormalizingController.normalize_params :form => 'C'
    assert NormalizingController.respond_to?(:params_normalization_form)
    assert NormalizingController.respond_to?(:params_normalization_form=)
    assert_equal 'C', NormalizingController.params_normalization_form, "Base controller should accept the setting"
    assert_equal 'KC', SubController.params_normalization_form, "The subcontroller should keep the setting"
    
    with_kcode('u') do
      post :call_param, :texts => {:a => 'блå ﬃ'}
      assert_success
      assert_equal normal_text, @response.body
    end

    NormalizingController.normalize_params :form => 'KC'
    assert_equal 'KC', NormalizingController.params_normalization_form

    with_kcode('u') do
      post :call_param, :texts => {:a => 'блå ﬃ'}
      assert_success
      assert_equal kc_normalized, @response.body
    end

    NormalizingController.normalize_params :form => 'C'
    assert_equal 'C', NormalizingController.params_normalization_form    

    NormalizingController.normalize_params
    assert_equal 'KC', NormalizingController.params_normalization_form        
  end
end