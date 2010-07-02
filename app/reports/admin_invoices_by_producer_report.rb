class AdminInvoicesByProducerReport < Ruport::Controller

  stage :list

  def setup
    delivery_cycle_id = options[:delivery_cycle_id]
    puts "delivery_cycle_id is #{delivery_cycle_id}"
    return unless delivery_cycle_id
    
    raw_data = LineItem.report_table(:all, 
      :joins => "inner join products on line_items.product_id = products.id inner join orders on orders.id = line_items.order_id", 
      :conditions => ["orders.delivery_cycle_id = ? and orders.final = true", delivery_cycle_id],
      :methods=>[:total_price_in_dollars,:item_count], 
      :include=>{ :product=>{:only=>[:ordering_unit,:title,:account_id],:methods=>[:account_name, :price_in_dollars, :sold_by_weight, :estimated_price]}, 
                  :order=>{:methods=>[:user_name] } }, 
      :transforms=> lambda { |r|
        r['Producer Name'] = r['product.account_name']
        r['Producer ID'] = r['product.account_id']
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
    
    raw_data = raw_data.sub_table(['Producer Name', 'Producer ID', 'Customer Name', 'Product ID', 'Product Name', 'Item Count', 'Ordering Unit', 'Price per Unit', 'Total Price', 'Total Price Value'])
    
    data_grouping = Ruport::Data::Grouping.new(raw_data, :by=>['Producer Name','Customer Name'])
    puts "data grouping is: #{data_grouping.inspect}\n\n"
    
    grouping_with_totals = Ruport::Data::Grouping.new
    
    return if data_grouping.nil? 
    
    data_grouping.each do |producer_name, invoices|
      customer_grouping = data_grouping.subgrouping(producer_name)
      next unless customer_grouping
      puts "customer grouping is #{customer_grouping.inspect}\n\n"
      customer_grouping_with_totals = Ruport::Data::Grouping.new     
      customer_grouping.each do |customer_name, invoice|
        subtotal   = invoice.sum('Total Price Value')
        market_fee = subtotal * PRODUCER_SURCHARGE
        total      = subtotal - market_fee 
        invoice.remove_column('Total Price Value')
        (((invoice << [nil,nil,nil,nil,'Subtotal',as_money(subtotal)]) << [nil,nil,nil,nil,'Market Fee',as_money(market_fee)]) << [nil,nil,nil,nil,'Total',as_money(total)])                        
      end
    end
    
    self.data = data_grouping
    
  end
  
  def as_money(q)
    sprintf("$%.2f",q)
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
      if !data
        output << textile("*no data*") unless data
      else 
        data.each do |producer_name,invoices|
          output << "<h2>#{producer_name}:</h2>"
          customer_grouping = data.subgrouping(producer_name)
          output << customer_grouping.to_html
        end
      end
      output << "<p>* #{SOLD_BY_WEIGHT_EXPLANATION}</p>"
    end
  end
  
  formatter :pdf do
    build :list do
      pad(10) { add_text "Invoice" }
      if data
        data.each do |producer_name,invoices|
          pad(10) { add_text "#{producer_name}:"}
          customer_grouping = data.subgrouping(producer_name)
          render_grouping customer_grouping, options.to_hash.merge(:formatter => pdf_writer)
        end
        pad(10) { add_text "* #{SOLD_BY_WEIGHT_EXPLANATION}"}
      end
    end
  end
  

end


