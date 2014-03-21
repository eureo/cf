class CsvFile < ActiveRecord::Base
  acts_as_attachment :storage => :file_system, :max_size => 2.megabytes, :content_type => 'text/plain'
  validates_as_attachment
  
  def get_emails
    case self.format
    when 'csv'  
      emails = FasterCSV.read(self.full_filename)
      emails = emails[0]
    when 'foxmail'
      faster_csv_rows = FasterCSV.read(self.full_filename, { :headers => true, :col_sep => ',', :row_sep => :auto})
      emails = []
      faster_csv_rows.each {|row| emails << row.values_at(1)[0] }
    end
    return emails
  end
  
end
