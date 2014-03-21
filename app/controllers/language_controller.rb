class LanguageController < ApplicationController

  def set_lang
    @session['lang'] = params[:id]
    redirect_to last_request_uri
  end
	
end
