module Admin::CmsHelper

	def link_if_permit(logicstring, name, options = {}, html_options = nil, *parameters_for_method_reference)
		if permit? logicstring
			result = "#{link_to name, options, html_options, *parameters_for_method_reference}"
		end
	end
	
	# display categories in a tree
	# options :
	#   controller => choose which controller should be bind to the tree
	#   action => choose which action should be bind to the tree
	def display_category_tree(root, recurs = {}, options = {})
		# we retrieve data that allow the recursivity
		recurs_data = { :html => "", :n => 0 }
		recurs_data.update(recurs) if recurs.is_a?(Hash)
		# we retrieve the options
		configuration = { :controller => params[:controller], :action => "index" }
		configuration.update(options) if options.is_a?(Hash)
		html = recurs_data[:html] || "" 
		n = recurs_data[:n] || 0
		n.times { html << "\t" }
		html <<  "<ul id=\"#{root.name.downcase}\">\n"
		(n+1).times { html << "\t" }
		html << "<li>"
		# the initial category root is not editable
		if root == root.class.root and configuration[:action] == 'edit'
			html << root.name
		else
			html << (link_to root.name, { :controller => configuration[:controller], :action => configuration[:action] , :params => {:id => root.id}} )
		end
		html << "</li>\n"
		root.children.each do |child|
			# call to itself to make it recursive
			display_category_tree(child, { :html => html , :n => n+1 }, options)
		end
		n.times { html << "\t" }
		html << "</ul>\n"
	end

	def display_category_rows(root, recurs = {}, options = {})
    # options
    admin = options[:admin] || 'admin'
		# we retrieve data that allow the recursivity
		recurs_data = { :html => "", :n => 0 }
		recurs_data.update(recurs) if recurs.is_a?(Hash)
		html = recurs_data[:html] || "" 
		n = recurs_data[:n] || 0
		html << "<tr #{cycle(""," class='odd'")}>"
		html <<  "<td>"
		n.times { html << "&nbsp;&nbsp;" }
		html << "#{link_to root.name, :action => 'show', :id => root}"
		html << "</td>"
		html << "<td>"
		# the initial category root is not editable
		if permit? admin
			html << "#{link_to l('edit'), :action => 'edit', :id => root}" unless root == root.class.root
		end
		html << "</td>"
		html << "</tr>"
		root.children.each do |child|
			# call to itself to make it recursive
			display_category_rows(child, {:html => html , :n => n+1}, options)
		end
		html
	end

  def display_root_rows_for_items_summary(root, item, recurs = {}, options = {})
    controller = options[:controller] || '/admin/cms/categories'
    action = options[:action] || 'show'
		# we retrieve data that allow the recursivity
		recurs_data = { :html => "", :n => 0 }
		recurs_data.update(recurs) if recurs.is_a?(Hash)
		html = recurs_data[:html] || "" 
		n = recurs_data[:n] || 0
		html << "<tr #{cycle(""," class='odd'")}>"
		html <<  "<td>"
		n.times { html << "&nbsp;&nbsp;" }
		html << "#{link_to root.name, :controller => controller, :action => action, :id => root}"
		html << "</td>"
		html << "<td>#{root.send(item).count(:conditions => 'published = 0 and archived = 0')}</td>"
		html << "<td>#{root.send(item).count(:conditions => 'published != 0 and archived = 0')}</td>"
		html << "<td>#{root.send(item).count(:conditions => 'published = 0 and archived != 0')}</td>"
		html << "</tr>"
		root.children.each do |child|
			# call to itself to make it recursive
			display_root_rows_for_items_summary(child, item, {:html => html , :n => n+1}, options )
		end
		html
	end

	def display_articles(articles, options = {}, html_options = {} )
		defaults = { :title => l('Articles') }
		html_defaults = { :class => "articles" }
		options = defaults.update(options)
		html_options = html_defaults.update(html_options)
		html = ""
		if articles.size > 0
			html << "<table cellpadding=\"0\" cellspacing=\"0\" class=\"#{html_options[:class]}\">"
			html << "<thead>"
			html << "<tr>"
			html << "<th>#{options[:title]}</th>"
			html << "</tr>"
			html << "</thead>"
			html << "<tbody>"
			articles.each do |article|
				html << "<tr #{cycle(""," class='odd'")}>"
				html << "<td>#{link_to article.title, :controller => options[:controller], :action => :show, :id => article}</td>"
				html << "</tr>"
			end
			html << "</tbody>"
			html << "</table>"
		end
	end

	def category_path(category, options = {})
    #options
    controller = options[:controller] || '/admin/cms/categories'
    html = ""
		html << "<div id=\"category-path\">"
		ancestors = category.ancestors
		ancestors.reverse.each do |ancestor|
			html << "#{link_to ancestor.name.downcase, :controller => controller, :action => 'show', :id => ancestor}"
			html << " > "
		end
		html << "#{link_to category.name.downcase, :controller => controller, :action => 'show', :id => category}"
		html << "</div>"
	end

  CategoryLine = Struct.new(:id, :name)

  def category_struct
    cat, level = [], 0
    root = Category.root
    cat << CategoryLine.new(root.id, root.name)
    cat << find_all_children(root, level)
    cat.flatten
  end

  def find_all_children(category, level)
    cat = []
    if category.children.size > 0
      level += 1
      category.children.each do |subcat|
          cat << CategoryLine.new(subcat.id, "-  " * level + subcat.name)
        if subcat.children.size > 0
          cat << find_all_children(subcat, level)
        end
      end
    end
    return cat
  end

end
