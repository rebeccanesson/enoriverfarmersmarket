class DeliveryCycle < ActiveRecord::Base
  
  validate :does_not_overlap
  validate :in_order
  validate :non_empty
  has_many :orderables
 
  @@phases =           ["NOT_OPEN", 
                        "EDIT_OPEN", 
                        "EDIT_CLOSED", 
                        "ORDER_OPEN", 
                        "ORDER_CLOSED", 
                        "DELIVERY_OPEN", 
                        "DELIVERY_CLOSED", 
                        "PICKUP_OPEN", 
                        "CLOSED"] 
  @@phase_names =      ["not open yet", 
                        "open for producers", 
                        "between producer editing and ordering", 
                        "open for ordering", 
                        "between ordering and delivery", 
                        "in delivery", 
                        "between delivery and pickup", 
                        "in pickup", 
                        "closed"]
  @@user_phase_names =                       ["not open yet", 
                                              "not open yet", 
                                              "not open yet", 
                                              "open for ordering", 
                                              "between ordering and pickup", 
                                              "between ordering and pickup", 
                                              "between ordering and pickup", 
                                              "in pickup", 
                                              "closed"]
 cattr_accessor :phases, :phase_names, :user_phase_names
  
  def self.current 
    cycle = DeliveryCycle.find(:first, :conditions => ["edit_open <= ? and pickup_close > ?", Time.now, Time.now])
    unless cycle
      cycle = DeliveryCycle.find(:first, :conditions => ["edit_open >= ?", Time.now], :order => "edit_open ASC")
    end
    unless cycle
      cycle = DeliveryCycle.find(:first, :conditions => ["pickup_close > ?", Time.now], :order => "pickup_close DESC")
    end
    cycle
  end
  
  def self.current_phase
    res = nil
    cycle = self.current
    if cycle
      res = cycle.current_phase
    end
    res
  end
  
  def self.current_phase_name(producer=false)
    if producer
      @@phase_names[@@phases.index(current_phase)]
    else 
      @@user_phase_names[@@phases.index(current_phase)]
    end
  end
  
  def is_current
    @@phases[1..7].include?(self.current_phase)
  end
  
  def is_future
    self.current_phase == @@phases[0]
  end
  
  def is_past
    self.current_phase == @@phases[8]
  end
  
  def is_edit
    self.current_phase == @@phases[1]
  end
  
  def is_order 
    self.current_phase == @@phases[3]
  end
  
  def is_delivery
    self.current_phase == @@phases[5]
  end
  
  def is_pickup
    self.current_phase == @@phases[7]
  end
  
  def is_after_order 
    @@phases.index(self.current_phase) > 3
  end
  
  def permits_product_editing
    idx = @@phases.index(self.current_phase)
    idx < 3 or idx == 8
  end
  
  def current_phase
    if Time.now < self.edit_open
      DeliveryCycle.phases[0]
    elsif self.edit_open <= Time.now and Time.now <= self.edit_close
      DeliveryCycle.phases[1]
    elsif self.edit_close <= Time.now and Time.now <= self.order_open
      DeliveryCycle.phases[2]
    elsif self.order_open <= Time.now and Time.now <= self.order_close
      DeliveryCycle.phases[3]
    elsif self.order_close <= Time.now and Time.now <= self.delivery_open
      DeliveryCycle.phases[4]
    elsif self.delivery_open <= Time.now and Time.now <= self.delivery_close
      DeliveryCycle.phases[5]
    elsif self.delivery_close <= Time.now and Time.now <= self.pickup_open
      DeliveryCycle.phases[6]
    elsif self.pickup_open <= Time.now and Time.now <= self.pickup_close
      DeliveryCycle.phases[7]
    elsif self.pickup_close < Time.now
      DeliveryCycle.phases[8]
    else
      DeliveryCycle.phases[8]
    end
  end
  
  def current_phase_end
    if current_phase == phases[0]
      edit_open
    elsif current_phase == phases[1]
      edit_close
    elsif current_phase == phases[2]
      order_open
    elsif current_phase == phases[3]
      order_close
    elsif current_phase == phases[4]
      delivery_open
    elsif current_phase == phases[5]
      delivery_close
    elsif current_phase == phases[6]
      pickup_open
    elsif current_phase == phases[7]
      pickup_close
    else
      # not sure how to handle this case
      pickup_close
    end
  end
    
  
  def does_not_overlap
    cycles = DeliveryCycle.find(:all, :conditions => ["edit_open <= ? and pickup_close > ?", edit_open, edit_open])
    cycles.reject! { |c| c.id == self.id } if self.id
    if cycles.size > 0 
      errors.add_to_base("Delivery cycles may not overlap")
      return
    end
    cycles = DeliveryCycle.find(:all, :conditions => ["edit_open <= ? and pickup_close > ?", pickup_close, pickup_close])
    cycles.reject! { |c| c.id == self.id } if self.id
    if cycles.size > 0 
      errors.add_to_base("Delivery cycles may not overlap")
      return
    end
    cycles = DeliveryCycle.find(:all, :conditions => ["edit_open >= ? and pickup_close < ?", edit_open, pickup_close])
    cycles.reject! { |c| c.id == self.id } if self.id
    if cycles.size > 0 
      errors.add_to_base("Delivery cycles may not overlap")
      return
    end
    cycles = DeliveryCycle.find(:all, :conditions => ["edit_open <= ? and pickup_close > ?", edit_open, pickup_close])
    cycles.reject! { |c| c.id == self.id } if self.id
    if cycles.size > 0 
      errors.add_to_base("Delivery cycles may not overlap")
      return
    end        
  end
  
  def in_order
    unless edit_open      <= edit_close and 
           edit_close     <= order_open and 
           order_open     <= order_close and 
           order_close    <= delivery_open and
           delivery_open  <= delivery_close and
           delivery_close <= pickup_open and
           pickup_open    <= pickup_close
      errors.add_to_base("The dates in a delivery cycle must be in order.")
    end
  end
  
  def non_empty
    unless edit_open < pickup_close
      errors.add_to_base("Delivery cycles must span some time.")
    end
  end
  
end
