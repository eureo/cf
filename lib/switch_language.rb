require 'localization_settings'
module Franck
  module SwitchLanguage

    def locale
      if not session['lang'].nil?
        LocalizationSettings::CONFIG[:default_language] = session['lang']
      else
        session['lang'] = 'fr'
      end
    end
  
    # store current uri in  the session.
    # we can return to this location by calling return_location
    def sl_store_location
      session['sl-return-to'] = request.request_uri
    end

    # move to the last store_location call or to the passed default one
    def sl_redirect_to_stored_or_default(default)
      if session['sl-return-to'].nil?
        redirect_to default
      else
        redirect_to_url session['sl-return-to']
        session['sl-return-to'] = nil
      end
    end

  end
end
