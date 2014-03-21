class CreateHtmlNewsletter < ActiveRecord::Migration
  def self.up
    create_table :html_newsletters, :options => 'DEFAULT CHARSET=UTF8' do |t|
      t.column :title, :string
      t.column :from, :string
      t.column :subject, :string
      t.column :body_head, :text
			t.column :body_head_html, :text
			t.column :body_left, :text
			t.column :body_left_html, :text
			t.column :body_right, :text
			t.column :body_right_html, :text
			t.column :body_foot, :text
			t.column :body_foot_html, :text
			t.column :permalink, :string
			t.column :created_at, :datetime
			t.column :updated_at, :datetime
			t.column :published_at, :datetime
    end
  end

  def self.down
    drop_table :html_newsletters
  end
end

