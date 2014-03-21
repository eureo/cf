class Admin::BaseController < ApplicationController
	layout 'admin'
  include AuthenticatedSystemUser
	before_filter :login_required
	access_control :DEFAULT => 'user'

	protected

  def permission_denied
		redirect_to :controller => '/account', :action => 'denied'
		return false
  end

end
