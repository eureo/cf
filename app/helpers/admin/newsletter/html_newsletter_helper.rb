module Admin::Newsletter::HtmlNewsletterHelper
	
	def show_current_cached_page(html_newsletter)
		html = []
		html << l('Current ')
		unless html_newsletter.published_at.nil?
			html << "(#{html_newsletter.published_at.to_formatted_s(:eu_format)})"
		end
		html << " : "
		
		cached_page_url = RAILS_ROOT + "/public/cache/newsletter/show/#{html_newsletter.permalink}.html"
		
		if File.exist?(cached_page_url) && !html_newsletter.nil?
			html << (link_to newsletter_path(html_newsletter), newsletter_path(html_newsletter))
		else
			html << l('nothing')
		end
		return html
	end
end