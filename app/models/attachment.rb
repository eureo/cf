class Attachment < ActiveRecord::Base
	file_column :file
	belongs_to :article
end
