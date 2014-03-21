module ActionController
  # Allows you to configure the options for Unicode normalization of all incoming CGI
  # data. All the CGI parameters are going to be normalized into the form you supply
  # in a pre-filter:
  #
  #   class ApplicationController < ActionController::Base
  #     normalize_unicode_params :form => 'C'
  #   end
  #
  # Bytestrings that are not valid UTF-8 are not going to be normalized.
  module Normalization
    
    def self.included(base) #:nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    end

    class UnknownNormalizationOptions < RuntimeError #:nodoc:
    end

    module ClassMethods #:nodoc:
      
      # Accomodate Rails Edge
      if defined?(ActiveSupport::Multibyte::NORMALIZATIONS_FORMS)
        NORMALIZATION_FORMS = ActiveSupport::Multibyte::NORMALIZATIONS_FORMS
      else
        NORMALIZATION_FORMS = ['C', 'KC', 'D', 'KD']
      end
      
      ALLOWED_OPTIONS = [:form]

      # Enables normalization of incoming CGI string parameters. Files and StringIO objects are left
      # unaltered, both keys and values are going to be normalized.
      def normalize_unicode_params(*options)
        opts = options.pop || {:form => ActiveSupport::Multibyte::DEFAULT_NORMALIZATION_FORM }
        raise UnknownNormalizationOptions,
          "Unknown normalization options #{opts.inspect}" unless opts.keys == ALLOWED_OPTIONS
        raise UnknownNormalizationOptions,
          "Unknown normalization form #{opts[:form]}" unless NORMALIZATION_FORMS.include?(opts[:form])

        # We add the filter if normalization form was not defined for this controller or it's ancestor
        unless self.respond_to?(:params_normalization_form)
          self.class_inheritable_accessor(:params_normalization_form)
          self.before_filter do | ctr |
            ctr.run_normalize_params(ctr.class.params_normalization_form)
          end
        end
        # and assign the setting
        self.params_normalization_form = opts[:form]
      end
      
      alias_method :normalize_params, :normalize_unicode_params
    end
        
    module InstanceMethods  #:nodoc:
      # Will normalize all incoming params to the supplied form
      def run_normalize_params(form) #:nodoc:
        if $KCODE == 'UTF8'
          normalize_strings_in_hash(params, form)
        end
        true
      end

      def map_normalization(str, form)
        return str unless(str.is_a?(String) && str.is_utf8?)
        str.chars.normalize!(form) && str.chars.strip!
      end
      
      def normalize_strings_in_hash(h, form) #:nodoc:
        h.each_pair do | k, v |
          if v.is_a?(Hash)
            normalize_strings_in_hash(v, form)
          elsif v.is_a?(Array)
            v.map! do |el| 
              map_normalization(el, form)
            end
          elsif v.is_a?(String) && v.is_utf8? && !v.blank?
            map_normalization(v, form)
          end
        end
      end
    end
  end
end