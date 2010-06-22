class Product < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  has_many :orderables, :dependent => :destroy
  has_many :available_orderables, :class_name => 'Orderable', :conditions => "status='Available'"
  has_many :carted_orderables, :class_name => 'Orderable', :conditions => "status='In Cart'"
  has_many :ordered_orderables, :class_name => 'Orderable', :conditions => "status='Ordered'"
  has_many :line_items
  
  validates_presence_of :account_id
  
  def self.by_category
    Category.products_by_category
  end
  
  def formatted_price
    "$#{price_per_unit / 100}"
  end
  
  def self.facet(products)
    facets = { :statuses => {:available => 0}, :categories => {}, :accounts => {} }
    Category.all.each { |c| facets[:categories][c.id] = 0 }
    Account.all.each { |a| facets[:accounts][a] = 0 }
    
    products.each do |prod|
      facets[:statuses][:available] += 1 if prod.available_orderables.size > 0
      if prod.category
        cats = [prod.category] + prod.category.ancestors
        cats.each { |cat| facets[:categories][cat.id] += 1 }
      end
      facets[:accounts][prod.account] += 1
    end
    
    facets
  end
  
end
