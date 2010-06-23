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
      :include => { :product=>{:only=>[:price_per_unit,:ordering_unit,:title] } }, 
      :transforms => lambda { |r|
        r['Product ID'] = r['product_id']
        r['Product Name'] = r['product.title']
        r['Item Count'] = r['item_count']
        r['Ordering Unit'] = r['product.ordering_unit'] 
        r['Price per Unit'] = r['product.price_per_unit']
        r['Total Price'] = r['total_price']
      }
    )
    
    return if raw_data.data.empty?

    raw_data = raw_data.sub_table(['Product ID', 'Product Name', 'Item Count', 'Ordering Unit', 'Price per Unit', 'Total Price'])
    
    # totals = Ruport::Data::Table.new :data => [["Subtotal", nil, nil, nil, nil, raw_data.sum('PRX Cut'), raw_data.sum('Discount'), raw_data.sum('Subsidy'), raw_data.sum('Unspent Point Value') ]], 
    #                                   :column_names => ["Event", "Date", "Account Name", "Path", "List Price", "PRX Cut", "Discount", "Subsidy", "Unspent Point Value"]
    # 
    #    raw_data = totals + raw_data
    
    self.data = raw_data
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


