class ProducerInvoiceByProductReport < Ruport::Controller

  stage :list

  def setup
    delivery_cycle_id = options[:delivery_cycle_id]
    account_id = options[:account_id]
    puts "delivery_cycle_id is #{delivery_cycle_id} and account_id is #{account_id}"
    return unless delivery_cycle_id and account_id
    
    raw_data = LineItem.report_table(:all, 
      :joins => "inner join products on line_items.product_id = products.id inner join orders on orders.id = line_items.order_id", 
      :conditions => ["products.account_id = ? and orders.delivery_cycle_id = ? and orders.final = true", account_id, delivery_cycle_id],
      :methods=>[:total_price_in_dollars,:item_count], 
      :include=>{ :product=>{:only=>[:ordering_unit,:title],:methods=>[:price_in_dollars,:sold_by_weight,:estimated_price]}, 
                  :order=>{:methods=>[:user_name] } }, 
      :transforms=> lambda { |r|
        r['Customer Name'] = r['order.user_name']
        r['Product ID'] = r['product_id']
        r['Product Name'] = r['product.title']
        r['Item Count'] = r['item_count']
        r['Ordering Unit'] = r['product.ordering_unit'] 
        r['Price per Unit'] = (r['product.sold_by_weight'] ? "#{as_money(r['product.estimated_price'])}*" : as_money(r['product.price_in_dollars']))
        r['Total Price'] = (r['product.sold_by_weight'] ? "#{as_money(r['total_price_in_dollars'])}*" : as_money(r['total_price_in_dollars']))
        r['Total Price Value'] = r['total_price_in_dollars']
      }
    )
    
    return if raw_data.data.empty?

    raw_data = raw_data.sub_table(['Customer Name', 'Product ID', 'Product Name', 'Item Count', 'Ordering Unit', 'Price per Unit', 'Total Price', 'Total Price Value'])
    
    data_grouping = Ruport::Data::Grouping.new(raw_data, :by=>'Product Name')
    grouping_with_totals = Ruport::Data::Grouping.new
    
    running_subtotal = 0
    running_market_fee = 0
    running_total = 0
    data_grouping.each do |name,group|
      subtotal   = group.sum('Total Price Value')
      market_fee = subtotal * PRODUCER_SURCHARGE
      total      = subtotal - market_fee 
      running_subtotal += subtotal
      running_market_fee += market_fee
      running_total += total
      group.remove_column('Total Price Value')
      grouping_with_totals << (((group << [nil,nil,nil,nil,'Subtotal',as_money(subtotal)]) << [nil,nil,nil,nil,'Market Fee',as_money(market_fee)]) << [nil,nil,nil,nil,'Total',as_money(total)])                        
    end
    
    total_group = Ruport::Data::Group.new :name => 'Summary',
                                          :data => [['Subtotal',as_money(running_subtotal)],['Market Fee',as_money(running_market_fee)],['Total',as_money(running_total)]], 
                                          :column_names => ['Total','Value']
    puts "before adding new group -> #{grouping_with_totals.inspect}\n\n\n\n\n"
    grouping_with_totals << total_group
    puts "after adding new group -> #{grouping_with_totals.inspect}\n\n\n\n\n"
    self.data = grouping_with_totals.sort_grouping_by { |g| (g.name == 'Summary' ? 1 : 0) }
  end
  
  def as_money(q)
    sprintf("$%.2f", q)
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
      output << "<p>* #{SOLD_BY_WEIGHT_EXPLANATION}</p>"
    end
  end
  
  formatter :pdf do
    build :list do
      pad(10) { add_text "Invoice" }
      render_grouping data, options.to_hash.merge(:formatter => pdf_writer)
      # pad(10) { add_text "* {SOLD_BY_WEIGHT_EXPLANATION}"}
    end
  end
  

end


