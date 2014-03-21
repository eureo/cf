module Admin::User::UserHelper

	def display_roles(roles)
		html = ""
		roles.each do |role|
			html << role.title + ', '
		end
		html.gsub(/,\s$/,"")
	end

	def display_roles_checkbox_two_columns(user)
		html = ""
		col = []
		col[0] = "<div>"
		col[1] = "<div>"
		html << "<h2>#{l('Roles')}</h2>"
		html << "<fieldset id='roles'>"
		roles = Role.find(:all, :order => :title)
		col_num = 0
		roles.each do |role|
			col_index = col_num % 2
			col[col_index] << "<p>"
			col[col_index] << "<input type='checkbox' name='roles[]' value='#{role.id}'" 
			col[col_index] << " checked='checked'" if user.roles.detect { |user_role| user_role == role } 
			col[col_index] << " />"
			col[col_index] << "<label>#{role.title}</label>"
			col[col_index] << "</p>"

			col_num += 1
		end
		col[0] << "</div>"
		col[1] << "</div>"
		html << col[0]
		html << col[1]
		html << "<br class='clear'>"
		html << "</fieldset>"
	end
	
end
