class ProducerInvoiceByCustomerReport < Ruport::Controller

  stage :list

  def setup
    delivery_cycle_id = options[:delivery_cycle_id]
    account_id = options[:account_id]
    puts "delivery_cycle_id is #{delivery_cycle_id} and account_id is #{account_id}"
    return unless delivery_cycle_id and account_id
    
    raw_data = LineItem.report_table(:all, 
      :joins => "inner join products on line_items.product_id = products.id inner join orders on orders.id = line_items.order_id", 
      :conditions => ["products.account_id = ? and orders.delivery_cycle_id = ?", account_id, delivery_cycle_id],
      :methods=>[:total_price,:item_count], 
      :include=>{ :product=>{:only=>[:price_per_unit,:ordering_unit,:title]}, 
                  :order=>{:methods=>[:user_name] } }, 
      :transforms=> lambda { |r|
        r['Customer Name'] = r['order.user_name']
        r['Product ID'] = r['product_id']
        r['Product Name'] = r['product.title']
        r['Item Count'] = r['item_count']
        r['Ordering Unit'] = r['product.ordering_unit'] 
        r['Price per Unit'] = r['product.price_per_unit']
        r['Total Price'] = r['total_price']
      }
    )
    
    return if raw_data.data.empty?

    raw_data = raw_data.sub_table(['Customer Name', 'Product ID', 'Product Name', 'Item Count', 'Ordering Unit', 'Price per Unit', 'Total Price'])
    
    data_grouping = Ruport::Data::Grouping.new(raw_data, :by=>'Customer Name')
    grouping_with_totals = Ruport::Data::Grouping.new
    
    data_grouping.each do |name,group|
      subtotal   = group.sum('Total Price')
      market_fee = subtotal * PRODUCER_SURCHARGE
      total      = subtotal - market_fee 
      grouping_with_totals << (((group << [nil,nil,nil,nil,'Subtotal',subtotal]) << [nil,nil,nil,nil,'Market Fee',market_fee]) << [nil,nil,nil,nil,'Total',total])                        
    end
    
    self.data = grouping_with_totals
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
      render_grouping data, options.to_hash.merge(:formatter => pdf_writer)
    end
  end
  

end


