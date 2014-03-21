class Image < ActiveRecord::Base
	file_column :name , :magick => { :versions => { "thumb" => "100x100" } }
	belongs_to :article
end
