class Product < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  has_many :orderables, :dependent => :destroy
  has_many :available_orderables, :class_name => 'Orderable', :conditions => "status='Available'"
  has_many :carted_orderables, :class_name => 'Orderable', :conditions => "status='In Cart'"
  has_many :ordered_orderables, :class_name => 'Orderable', :conditions => "status='Ordered'"
  has_many :line_items
  
  validates_presence_of :account_id
  validates_length_of :description, :maximum => 700
  
  acts_as_reportable
  
  @@storage_options = ['shelved', 'refrigerated', 'frozen']
  cattr_accessor :storage_options
  
  validates_presence_of :storage, :in => @@storage_options, :allow_nil => true
  
  def price_in_dollars
    price_per_unit/100.0 if price_per_unit; 
  end

  def price_in_dollars=(p)
    logger.debug("price in dollars is #{p.to_f}")
    logger.debug("price in dollars * 100 is #{p.to_f*100}")
    logger.debug("price per unit is #{(p.to_f*100).to_i}")
    self.price_per_unit = (p.to_f*100).to_i
  end
  
  def self.by_category
    Category.products_by_category
  end
  
  def formatted_price
    format("$%.2f",self.price_in_dollars)
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
      facets[:accounts][prod.account] += 1 if prod.account
    end
    
    facets
  end
  
  # for use by reports
  def account_name
    self.account.name
  end
  
end
