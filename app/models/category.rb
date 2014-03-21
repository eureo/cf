class Category < ActiveRecord::Base
	acts_as_tree :order => :position
	acts_as_list :scope => :parent_id
	has_many :articles, :order => "published_at desc"
	validates_presence_of :name

  before_destroy :delete_articles

  def to_param
    permalink
  end

	def stripped_name
    self.name.to_url
  end
  
  def published_articles
    Article.ez_find(:all, :include => :category, :order => "published_at desc") do |article, category|
      article.published == 1
      category.permalink == self.permalink
    end
  end

  def delete_articles
    articles = self.articles.find(:all)
    articles.each {|a| a.destroy }
  end
  
  def is_region?
    if self.parent.permalink == "regions"
      return true
    else
      return false
    end
  end
  
  def self.get_regions_and_articles_number
    root = Category.find_by_permalink("regions")
    regions = root.children.sort_by{|r| r.name }
    
    regions_and_number_of_articles = []
    
    for region in regions
      number_of_articles_in_category = Article.find(:all, :include => :category, :conditions => ["articles.category_id = ? and articles.published = ?", region.id, 1]).size
      number_of_articles_in_subcategory = Article.find(:all, :include => :category, :conditions => ["categories.parent_id = ? and articles.published = ?", region.id, 1]).size
      number_of_articles = number_of_articles_in_category + number_of_articles_in_subcategory
      regions_and_number_of_articles << [region, number_of_articles ]
    end
    
    return regions_and_number_of_articles
  end
  
  def belongs_to_region?
    categories = []
    categories << self
    categories << self.ancestors.reject!{|c| c.permalink == "root" }
    categories.flatten!
    region = categories.detect{|c| c.parent.permalink == "regions" }
    if region.nil?
      return false
    else
      return true
    end
  end 

	protected
	before_save :set_defaults

	def set_defaults
    if self.permalink.blank?
      permalink = self.stripped_name
      categories = Category.ez_find(:all) do |cat|
        cat.permalink =~ "#{permalink}%"
      end
      if categories.nil? or categories.size == 0
        self.permalink = permalink 
      else
        self.permalink = permalink + (categories.size + 1).to_s
      end
    end
	end

end
