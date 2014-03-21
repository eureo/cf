class AccountController < ApplicationController
  include AuthenticatedSystemUser
  layout 'login'
  observer :user_observer

  def index
    redirect_to(:action => 'signup') unless logged_in? or User.count > 0
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if current_user
      redirect_back_or_default(:controller => 'home', :action => 'index')
      flash[:notice] = "Logged in successfully"
      if params[:rememberme] == '1'
        self.current_user.remember_me
        cookies[:auth_token] = {:value => self.current_user.remember_token, :expires => 90.days.from_now }
      else
        current_user.forget_me if current_user.remember_token
      end
    else
      flash[:notice] = "Invalid username or password"
    end
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    @user.roles << Role.find_by_title('user')
    if @user.save
      redirect_back_or_default(:controller => 'account', :action => 'login')
      flash[:notice] = "Thanks for signing up! You will shorthly receive an email in order to activate your account."
    end
  end
  
  def logout
    self.current_user.forget_me if current_user
    self.current_user = nil
    cookies.delete :auth_token

    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => 'home', :action => 'index')
  end

  def denied
  end

  def activate
    if params[:id]
      @user = User.find_by_activation_code(params[:id])
      if @user and @user.activate
        self.current_user = @user
        redirect_back_or_default(:controller => '/account', :action => 'login')
        flash[:notice] = "Your account has been activated." 
      else
        flash[:error] = "Activation impossible : please check your activation code"
      end
    else
      flash.clear
    end
  end

  def forgot_password
    return unless request.post?
    if @user = User.find_by_email(params[:email])
      @user.forgot_password
      @user.save
      flash[:notice] = "A password reset link has been sent to your email address" 
      redirect_back_or_default(:controller => '/account', :action => 'login')
    else
      flash[:notice] = "Could not find an user with that email address" 
    end
  end

  def reset_password
    @user = User.find_by_password_reset_code(params[:id])
    raise if @user.nil?
   
    return unless request.post?
    if (params[:user][:password] == params[:user][:password_confirmation])
      self.current_user = @user #for the next two lines to work
      current_user.password_confirmation = params[:user][:password_confirmation]
      current_user.password = params[:user][:password]
      @user.reset_password
      if current_user.save
        flash[:notice] = "Password reset"
        redirect_back_or_default(:controller => '/account', :action => 'login') 
      end
    else
      flash[:notice] = "Password mismatch" 
    end  

  rescue
    logger.error "Invalid Reset Code entered" 
    flash[:notice] = "Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?" 
  end

  
end
