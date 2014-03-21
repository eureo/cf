class HtmlNewsletter < ActiveRecord::Base
  
  validates_presence_of :title
  validates_presence_of :subject
	
	def get_all_valid_emails
    #sector.newsletter_members.get_valid_emails.flatten.compact.uniq
  end

	def publish
		self.published_at = Time.now
		self.save
	end
	
	def stripped_subject
    self.subject.to_url
  end

	protected
	
	before_save :set_defaults, :transform_body

	def set_defaults
    if self.permalink.blank?
      permalink = self.stripped_subject
      newsletter = HtmlNewsletter.ez_find(:all) do |newsletter|
        newsletter.permalink =~ "#{permalink}%"
      end
      if newsletter.nil? or newsletter.size == 0
        self.permalink = permalink 
      else
        self.permalink = permalink + (newsletter.size + 1).to_s
      end
    end
  end
  
	def transform_body
		self.body_head_html = RedCloth.new(body_head.gsub(%r{</?notextile>}, '')).to_html if body_head
		self.body_left_html = RedCloth.new(body_left.gsub(%r{</?notextile>}, '')).to_html if body_left
		self.body_right_html = RedCloth.new(body_right.gsub(%r{</?notextile>}, '')).to_html if body_right
		self.body_foot_html = RedCloth.new(body_foot.gsub(%r{</?notextile>}, '')).to_html if body_foot
	end
	
	#def test2html
	#	self.body_before_html = body_before
	#	self.body_after_html = body_after
	#end
	
end
