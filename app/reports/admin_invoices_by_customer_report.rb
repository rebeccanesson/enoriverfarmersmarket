class AdminInvoicesByCustomerReport < Ruport::Controller

  stage :list

  def setup
    delivery_cycle_id = options[:delivery_cycle_id]
    puts "delivery_cycle_id is #{delivery_cycle_id}"
    return unless delivery_cycle_id
    
    raw_data = LineItem.report_table(:all, 
      :joins => "inner join products on line_items.product_id = products.id inner join orders on orders.id = line_items.order_id", 
      :conditions => ["orders.delivery_cycle_id = ? and orders.final = true", delivery_cycle_id],
      :methods=>[:total_price,:item_count], 
      :include=>{ :product=>{:only=>[:price_per_unit,:ordering_unit,:title,:account_id],:methods=>[:account_name]}, 
                  :order=>{:methods=>[:user_name] } }, 
      :transforms=> lambda { |r|
        r['Producer Name'] = r['product.account_name']
        r['Producer ID'] = r['product.account_id']
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
    
    raw_data = raw_data.sub_table(['Producer Name', 'Producer ID', 'Customer Name', 'Product ID', 'Product Name', 'Item Count', 'Ordering Unit', 'Price per Unit', 'Total Price'])
    
    data_grouping = Ruport::Data::Grouping.new(raw_data, :by=>['Customer Name','Producer Name'])
    puts "data grouping is: #{data_grouping.inspect}\n\n"
    
    grouping_with_totals = Ruport::Data::Grouping.new
    
    data_grouping.each do |producer_name, invoices|
      customer_grouping = data_grouping.subgrouping(producer_name)
      puts "customer grouping is #{customer_grouping.inspect}\n\n"
      customer_grouping_with_totals = Ruport::Data::Grouping.new     
      customer_grouping.each do |customer_name, invoice|
        subtotal   = invoice.sum('Total Price')
        market_fee = subtotal * MEMBER_SURCHARGE
        total      = subtotal + market_fee 
        (((invoice << [nil,nil,nil,nil,'Subtotal',subtotal]) << [nil,nil,nil,nil,'Market Fee',market_fee]) << [nil,nil,nil,nil,'Total',total])                        
      end
    end
    
    self.data = data_grouping
    
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
      data.each do |producer_name,invoices|
        output << "<h2>#{producer_name}:</h2>"
        customer_grouping = data.subgrouping(producer_name)
        output << customer_grouping.to_html
      end
      output << textile("*no data*") unless data
    end
  end
  
  formatter :pdf do
    build :list do
      pad(10) { add_text "Invoice" }
      data.each do |producer_name,invoices|
        pad(20) { add_text "#{producer_name}:"}
        customer_grouping = data.subgrouping(producer_name)
        render_grouping customer_grouping, options.to_hash.merge(:formatter => pdf_writer)
      end
    end
  end
  

end





