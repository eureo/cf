class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles, :force => true, :options => 'DEFAULT CHARSET=UTF8' do |t|
			t.column :category_id, :integer
      t.column :title, :string
			t.column :author, :string
			t.column :excerpt, :text
			t.column :excerpt_html, :text
			t.column :body, :text
			t.column :body_html, :text
			t.column :published, :boolean, :default => 0
			t.column :archived, :boolean, :default => 0
			t.column :created_at, :datetime
			t.column :updated_at, :datetime
			t.column :published_at, :datetime
			t.column :archived_at, :datetime
			t.column :permalink, :string
    end
  end

  def self.down
    drop_table :articles
  end
end
