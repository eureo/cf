class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :articles, :published
    
    add_index :articles, :permalink
    add_index :categories, :permalink
        
    add_index :taggings, :taggable_id
    add_index :taggings, :tag_id
    add_index :tags, :name
  end

  def self.down
    remove_index :articles, :published
  
    remove_index :articles, :permalink
    remove_index :categories, :permalink
  
    remove_index :taggings, :taggable_id
    remove_index :taggings, :tag_id
    remove_index :tags, :name
  end
end
