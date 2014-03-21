class Admin::User::UserController < Admin::User::BaseController

	def index
		list
		render :action => :list
	end

	def list
		@users = User.find(:all)
	end

	def show	
		@user = User.find(params[:id])
	end

	def edit
		@user = User.find(params[:id])
		@user.attributes = params[:user]
		@user.edition_mode = true
		if request.post?
			if @user.save
				@user.edition_mode = false
				flash[:notice] = "User was successfully updated"
				redirect_to :action => :list
			end
		end
	end

	def edit_user_roles
		@user = User.find(params[:id])
		# if no roles checked then delete all
		if params[:roles].nil?
			@user.roles.each { |role| @user.roles.delete(role) }
		else
			roles = params[:roles].collect { |role_id| Role.find(role_id) }
			roles.each do |role|
				@user.roles << role if !@user.roles.include?(role)
			end
			@user.roles.each { |role| @user.roles.delete(role) if !roles.include?(role) }
		end

		if @user.save
			flash[:notice] = "User's role was updated"
		end

		redirect_to :action => :list
	end

	def new
		@user = User.new(params[:user])
		if request.post?
			@user.roles << Role.find_by_title('user')
      @user.activated_at = Time.now
			if @user.save
				flash[:notice] = "User was successfully created"
				redirect_to :action => :list
			end
		end
	end

	def delete
		@user = User.find(params[:id])
		if @user.destroy
			flash[:notice] = "User was successfully deleted"
		end
		redirect_to :action => :list
	end
	
end
