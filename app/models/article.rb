class Article < ActiveRecord::Base
	belongs_to :category
	has_many :images
	has_many :attachments
	validates_presence_of :title
	acts_as_taggable
  
  def to_param
    permalink
  end

	def stripped_title
    self.title.to_url
  end

	def self.find_by_permalink(title)
		find(:first, :conditions => ["permalink = ?", title])
	end
	
	def self.find_published_by_permalink(permalink)
	  self.ez_find(:first) do |article|
      article.published == 1
      article.permalink == permalink
    end
  end

	def self.private_search(query)
		if !query.to_s.strip.empty?
      tokens = query.split.collect {|c| "%#{c.downcase}%"}
      find_by_sql(["SELECT * from articles WHERE #{ (["(LOWER(body) LIKE ? OR LOWER(excerpt) LIKE ? OR LOWER(title) LIKE ?)"] * tokens.size).join(" AND ") } ORDER by created_at DESC", *tokens.collect { |token| [token] * 3 }.flatten])
    else
      []
    end
	end

  def self.find_by_tag(tags)
    self.ez_find(:all, :include => [:taggings, :tags], :order => "published_at desc") do |article, tagging, tag|
      article.published == 1
      tagging.taggable_type == 'Article'
      tag.name === tags
    end
  end

  def self.full_text_search(q, options = {})
    return nil if q.nil? or q==""
    default_options = {:limit => 10, :page => 1}
    options = default_options.merge options
    options[:offset] = options[:limit] * (options.delete(:page).to_i-1)  
    results = Article.find_by_contents(q, options)
    return [results.total_hits, results]
  end

	protected

	before_save :set_defaults, :test2html, :transform_body

	def set_defaults
    if self.permalink.blank?
      permalink = self.stripped_title
      articles = Article.ez_find(:all) do |art|
        art.permalink =~ "#{permalink}%"
      end
      if articles.nil? or articles.size == 0
        self.permalink = permalink 
      else
        self.permalink = permalink + (articles.size + 1).to_s
      end
    end
  end

	def transform_body
		self.excerpt_html = RedCloth.new(excerpt.gsub(%r{</?notextile>}, '')).to_html if excerpt
		self.body_html = RedCloth.new(body.gsub(%r{</?notextile>}, '')).to_html if body
	end

	def test2html
		self.excerpt_html = excerpt
		self.body_html = body
	end
	
end
