class UserInvoiceReport < Ruport::Controller

  stage :list

  def setup
    delivery_cycle_id = options[:delivery_cycle_id]
    user_id = options[:user_id]
    puts "delivery_cycle_id is #{delivery_cycle_id} and user_id is #{user_id}"
    return unless delivery_cycle_id and user_id
    
    raw_data = LineItem.report_table(:all, 
      :joins => "inner join orders on orders.id = line_items.order_id",
      :conditions =>["orders.delivery_cycle_id = ? and orders.user_id = ?", delivery_cycle_id, user_id], 
      :methods=>[:total_price, :item_count], 
      :include => { :product=>{:only=>[:ordering_unit,:title], :methods => [:account_name,:price_in_dollars] } }, 
      :transforms => lambda { |r|
        r['Producer'] = r['product.account_name']
        r['Product ID'] = r['product_id']
        r['Product Name'] = r['product.title']
        r['Item Count'] = r['item_count']
        r['Ordering Unit'] = r['product.ordering_unit'] 
        r['Price per Unit'] = r['product.price_in_dollars']
        r['Total Price'] = r['total_price']
      }
    )
    
    return if raw_data.data.empty?

    raw_data = raw_data.sub_table(['Producer', 'Product ID', 'Product Name', 'Item Count', 'Ordering Unit', 'Price per Unit', 'Total Price'])
    
    data_grouping = Ruport::Data::Grouping.new(raw_data, :by=>'Producer')
    grouping_with_totals = Ruport::Data::Grouping.new
    
    running_subtotal = running_market_fee = running_total = 0
    data_grouping.each do |name,group|
      subtotal   = group.sum('Total Price')
      market_fee = subtotal * MEMBER_SURCHARGE
      total      = subtotal + market_fee 
      running_subtotal += subtotal
      running_market_fee += market_fee
      running_total += total
      grouping_with_totals << (((group << [nil,nil,nil,nil,'Subtotal',subtotal]) << [nil,nil,nil,nil,'Market Fee',market_fee]) << [nil,nil,nil,nil,'Total',total])                        
    end
    
    total_group = Ruport::Data::Group.new :name => 'Summary',
                                          :data => [['Subtotal',running_subtotal],['Market Fee',running_market_fee],['Total',running_total]]
    puts "before adding new group -> #{grouping_with_totals.inspect}\n\n\n\n\n"
    grouping_with_totals << total_group
    puts "after adding new group -> #{grouping_with_totals.inspect}\n\n\n\n\n"
    self.data = grouping_with_totals.sort_grouping_by { |g| (g.name == 'Summary' ? 1 : 0) }    

  end

  formatter :csv do
    build :list do
      output << data.to_csv if data
    end
  end

  formatter :text do
    build :list do
      output << data.to_text if data
    end
  end

  formatter :html do
    build :list do
      output << data.to_html if data
      output << textile("*no data*") unless data
    end
  end
  
  formatter :pdf do
    build :list do
      pad(10) { add_text "Invoice" }
      draw_table data
    end
  end
  

end


