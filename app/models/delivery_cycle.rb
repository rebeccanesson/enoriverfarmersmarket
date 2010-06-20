class DeliveryCycle < ActiveRecord::Base
  
  validate :does_not_overlap
  validate :in_order
  has_many :orderables
  
  @@phases = ["not open yet", "open for producers", "between producer editing and ordering", "open for ordering", "between ordering and delivery", "in delivery", "closed"]
  cattr_accessor :phases
  
  def self.current 
    cycle = DeliveryCycle.find(:first, :conditions => ["edit_open <= ? and delivery_close >= ?", Time.now, Time.now])
    unless cycle
      cycle = DeliveryCycle.find(:first, :conditions => ["edit_open > ?", Time.now], :order => "edit_open ASC")
    end
    unless cycle
      cycle = DeliveryCycle.find(:first, :conditions => ["delivery_close > ?", Time.now], :order => "delivery_close DESC")
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
  
  def is_current
    @@phases[1..6].include?(self.current_phase)
  end
  
  def is_future
    self.current_phase == @@phases[0]
  end
  
  def is_past
    self.current_phase == @@phases[6]
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
  
  def is_after_order 
    @@phases.index(self.current_phase) > 3
  end
  
  def permits_product_editing
    idx = @@phases.index(self.current_phase)
    idx < 3 or idx == 6
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
    elsif self.delivery_close < Time.now
      DeliveryCycle.phases[6]
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
    else
      # not sure how to handle this case
      delivery_close
    end
  end
    
  
  def does_not_overlap
    cycles = DeliveryCycle.find(:all, :conditions => ["edit_open <= ? and delivery_close >= ?", edit_open, edit_open])
    cycles.reject! { |c| c.id == self.id } if self.id
    if cycles.size > 0 
      errors.add_to_base("Delivery cycles may not overlap")
      return
    end
    cycles = DeliveryCycle.find(:all, :conditions => ["edit_open <= ? and delivery_close >= ?", delivery_close, delivery_close])
    cycles.reject! { |c| c.id == self.id } if self.id
    if cycles.size > 0 
      errors.add_to_base("Delivery cycles may not overlap")
      return
    end
    cycles = DeliveryCycle.find(:all, :conditions => ["edit_open >= ? and delivery_close <= ?", edit_open, delivery_close])
    cycles.reject! { |c| c.id == self.id } if self.id
    if cycles.size > 0 
      errors.add_to_base("Delivery cycles may not overlap")
      return
    end
    cycles = DeliveryCycle.find(:all, :conditions => ["edit_open <= ? and delivery_close >= ?", edit_open, delivery_close])
    cycles.reject! { |c| c.id == self.id } if self.id
    if cycles.size > 0 
      errors.add_to_base("Delivery cycles may not overlap")
      return
    end        
  end
  
  def in_order
    unless edit_open     <= edit_close and 
           edit_close    <= order_open and 
           order_open    <= order_close and 
           order_close   <= delivery_open and
           delivery_open <= delivery_close
      errors.add_to_base("The dates in a delivery cycle must be in order.")
    end
  end
  
end
