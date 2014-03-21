class Admin::User::RolesController < Admin::User::BaseController

	def index
		list
		render :action => :list
	end

	def list
		@roles = Role.find(:all, :order => :title)
	end

	def new
		@role = Role.new(params[:role])
		if request.post?
			if @role.save
				flash[:notice] = "Role was successfully created"
				redirect_to :action => :list
			end
		end			
	end

	def delete
		@role = Role.find(params[:id])
		if @role.destroy
			flash[:notice] = "Role was successfully deleted"
		end
		redirect_to :action => :list
	end

end
