module Franck
  module AdditionalTagFunctions
  
    def get_article_by_tags(wanted_tags)
      article = []
      article << Article.find_by_tag(wanted_tags)
      #article << Offer.find_by_tag(wanted_tags)
      article.flatten!
      article.compact!
    
      article.collect! do |a|
        tags = a.tags.collect do |t|
          t.name
        end
        if wanted_tags.all? {|t| tags.include? t}
          a
        end
      end

      article.compact!
      article = article.sort_by {|a| a.published_at }.reverse
    end

  end
end
