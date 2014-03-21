ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "home"
  # add home_url helper
  map.home '', :controller => 'home'
  
  map.regional_article 'region/article/:id', :controller => "region", :action => "article"

  map.connect 'articles/test_rss',
    :controller => "articles", :action => "test_rss"

	map.resources :articles
	map.resources :reactions
	map.resources :pages
	map.resources :news
	map.resources :agenda
	map.resources :category, :member_path => "/category/:permalink"
	map.resources :region, :member_path => "/region/:permalink"
  
  
  map.connect 'newsletter/thanks', :controller => "newsletter", :action => "thanks"
  map.connect 'newsletter/signout', :controller => "newsletter", :action => "signout"  
  map.connect 'newsletter/signingout', :controller => "newsletter", :action => "signingout"  
  map.connect 'newsletter/webhook', :controller => "newsletter", :action => "webhook"  
  map.connect 'newsletter/show/:title', :controller => 'newsletter', :action => 'show'
  map.resources :newsletter
  
  #map.thanks 'newsletter/thanks', :controller => 'newsletter', :action => 'thanks'
  # 
	#	:controller => 'newsletter', :action => 'show'
  
  
	# default   
  # map.index '', :controller  => 'articles', :action => 'index'
  map.admin 'admin', :controller  => 'admin', :action => 'index'

	# route to cms pages
	map.connect 'admin/cms/pages/:action/:id',
		:controller => 'admin/cms/pages' , :action => nil
	
	# route to cms categories
	map.connect 'admin/cms/categories/:action/:id',
		:controller => 'admin/cms/categories' , :action => nil

	# route to cms search
	map.connect 'admin/cms/search/:action/:id',
		:controller => 'admin/cms/search' , :action => nil

	# route to user admin
	map.connect 'admin/user/user/:action/:id',
		:controller => 'admin/user/user' , :action => nil
	
	map.connect 'admin/user/roles/:action/:id',
		:controller => 'admin/user/roles' , :action => nil
		
	# route to newsletter newletter
  map.connect 'admin/newsletter/newsletter/:action/:id',
  	:controller => 'admin/newsletter/newsletter' , :action => nil
  	
  # route to newsletter newletter
  map.connect 'admin/newsletter/html_newsletter/:action/:id',
  	:controller => 'admin/newsletter/html_newsletter' , :action => nil

	# route to newsletter import
  map.connect 'admin/newsletter/import/:action/:id',
   	:controller => 'admin/newsletter/import' , :action => nil

  # route to newsletter list
  map.connect 'admin/newsletter/list/:action/:id',
   	:controller => 'admin/newsletter/list' , :action => nil

	# route for permalink
	# map.connect 'home/:year/:month/:day/:title',
  #  :controller => 'home', :action => 'permalink',
  #  :year => /\d{4}/, :day => /\d{1,2}/, :month => /\d{1,2}/
    
  # map.connect 'home/:title',
  #  :controller => 'home', :action => 'permalink'
    
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)


  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
