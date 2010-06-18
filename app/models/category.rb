class Category < ActiveRecord::Base
  acts_as_tree

  has_many :products
  has_many :orderables, :through => :products
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :parent_id
  
  def self.root_categories
    Category.find(:all, :conditions => "parent_id is null")
  end 
  
  def self.products_by_category
    self.root_categories.map { |c| c.products_hash }
  end
  
  def products_hash
    hash = { 
      :name => self.name_chain,
      :products => self.products,
      :children => self.children.map { |c| c.products_hash }
    }
  end
  
  def name_chain
    if self.parent
      self.parent.name_chain + " >> " + self.name
    else 
      self.name
    end
  end

end
