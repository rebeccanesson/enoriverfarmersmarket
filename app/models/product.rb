class Product < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  has_many :orderables, :dependent => :destroy
  has_many :available_orderables, :class_name => 'Orderable', :conditions => "status='Available'"
  has_many :carted_orderables, :class_name => 'Orderable', :conditions => "status='In Cart'"
  has_many :ordered_orderables, :class_name => 'Orderable', :conditions => "status='Ordered'"
  has_many :line_items
  
  validates_presence_of :account_id
  validates_presence_of :title
  validates_presence_of :category_id
  validates_presence_of :ordering_unit
  validates_presence_of :price_per_unit
  validates_numericality_of :price_per_unit
  validates_presence_of :storage
  validates_length_of :description, :maximum => 700
  validates_presence_of :min_weight, :if => Proc.new { |prod| prod.ordering_unit == SOLD_BY_WEIGHT }
  validates_presence_of :max_weight, :if => Proc.new { |prod| prod.ordering_unit == SOLD_BY_WEIGHT }
  
  acts_as_reportable
  
  @@storage_options = ['shelved', 'refrigerated', 'frozen']
  cattr_accessor :storage_options
  
  SOLD_BY_WEIGHT = 'each, priced by the pound'
  @@ordering_units = ['each', 'pound', SOLD_BY_WEIGHT, 'bag', 'bunch', 'pint'].sort
  cattr_accessor :ordering_units
  
  validates_presence_of :storage, :in => @@storage_options, :allow_nil => true
  validates_presence_of :ordering_unit => @@ordering_units
  
  def self.per_page
    10
  end
  
  def available_orderables_in_cycle(cycle)
    return 0 unless cycle
    self.available_orderables.select { |o| o.delivery_cycle.id == cycle.id }
  end

  def carted_orderables_in_cycle(cycle)
    return 0 unless cycle
    self.carted_orderables.select { |o| o.delivery_cycle.id == cycle.id }
  end
  
  def ordered_orderables_in_cycle(cycle)
    return 0 unless cycle
    self.ordered_orderables.select { |o| o.delivery_cycle.id == cycle.id }
  end 
  
  def price_in_dollars
    price_per_unit/100.0 if price_per_unit; 
  end

  def price_in_dollars=(p)
    logger.debug("price in dollars is #{p.to_f}")
    logger.debug("price in dollars * 100 is #{p.to_f*100}")
    logger.debug("price per unit is #{(p.to_f*100).to_i}")
    self.price_per_unit = (p.to_f*100).to_i
  end
  
  def sold_by_weight
    ordering_unit == SOLD_BY_WEIGHT
  end
  
  def estimated_price
    if ordering_unit == SOLD_BY_WEIGHT
      (price_per_unit * average_weight) / 100.0 
    else 
      price_in_dollars
    end
  end
  
  def self.by_category
    Category.products_by_category
  end
  
  def formatted_price
    format("$%.2f",self.price_in_dollars)
  end
  
  def formatted_estimated_price
    format("$%.2f",self.estimated_price)
  end
  
  def average_weight
    return nil unless self.ordering_unit == SOLD_BY_WEIGHT
    (self.min_weight + self.max_weight) / 2.0
  end
  
  def self.facet(products,cycle)
    facets = { :statuses => {:available => 0}, :categories => {}, :accounts => {} }
    Category.all.each { |c| facets[:categories][c.id] = 0 }
    Account.all.each { |a| facets[:accounts][a] = 0 }
    
    products.each do |prod|
      facets[:statuses][:available] += 1 if prod.available_orderables_in_cycle(cycle).size > 0
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
  
  def can_make_orderable(delivery_cycle)
    self.created_at < delivery_cycle.order_open
  end
  
  def category_prefix
    return 'Uncategorized' unless self.category
    prefix = self.category.name
    cat = self.category
    while cat.parent and cat.parent.parent
      cat = cat.parent
      prefix = cat.name + ':' + prefix
    end
    prefix
  end
  
  def self.alphabetize(prods)
    prods.sort do |x,y| 
      Product.compare(x,y)
    end
  end
  
  def self.compare(x,y)
    return 0 unless x.category and y.category
    return 1 unless x.category
    return -1 unless y.category
    
    xcatlist = x.category.ancestors.collect { |a| a.name }.reverse << x.category.name
    ycatlist = y.category.ancestors.collect { |a| a.name }.reverse << y.category.name 
    
    while xcatlist.size > 0 and ycatlist.size > 0 
      res = (xcatlist.shift <=> ycatlist.shift)
      return res unless res == 0
    end
    
    return 0 if xcatlist.size == 0 and ycatlist.size == 0
    return 1 if xcatlist.size == 0 
    return -1 if ycatlist.size == 0
  end
  
end
