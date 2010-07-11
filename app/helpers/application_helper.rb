# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def default_title
    "Online Market"
  end
  
  def date_format(date)
    date.strftime("%a %b %d %Y, %l%p")
  end
  
  def date_fmt(date)
    date.strftime("%a %b %d, %l%p")
  end
  
  def can_edit(item)
    res = false
    if item.is_a?(Product) and current_user and (current_user.admin or current_user.managed_accounts.include?(item.account))
      res = true
    elsif item.is_a?(Account) and current_user and (current_user.admin or current_user.managed_accounts.include?(item))
      res = true
    end
    res
  end
  
  def is_owner(item)
    res = false
    if item.is_a?(Account) and current_user and (current_user.admin or current_user.owned_accounts.include?(item))
      res = true
    end
    res
  end
  
  def image_for(item)
    res = "<img src='/images/logo.jpg' />"
    if item.is_a?(Product)
      if item.image_url and !item.image_url.blank?
        res = "<img src='#{item.image_url}' />"
      elsif item.category 
        cat_image = item.category.image
        if cat_image and !cat_image.blank? 
          res = "<img src='#{cat_image}' />"
        end
      elsif item.account and item.account.logo_url and !item.account.logo_url.blank? 
        res = "<img src='#{item.account.logo_url}' />"
      end
    elsif item.is_a?(Category)
      cat_image = item.image
      if cat_image and !cat_image.blank? 
        res = "<img src='#{cat_image}' />"
      end
    elsif item.is_a?(Account)
      if item.logo_url and !item.logo_url.blank?
        res = "<img src='#{item.logo_url}' />"
      end
    end
    res
  end
  
  def present_cycle(c)
    if (@current_user and (@current_user.admin or @current_user.is_producer))
      ret = '<b>' + DeliveryCycle.current_phase_name(true)   + '</b><br />'
      ret += '<b>Set Up:</b> '   + date_format(c.edit_open)     + ' to ' + date_format(c.edit_close)     + '<br />'
      ret += '<b>Ordering:</b> ' + date_format(c.order_open)    + ' to ' + date_format(c.order_close)    + '<br />'
      ret += '<b>Delivery:</b> ' + date_format(c.delivery_open) + ' to ' + date_format(c.delivery_close) + '<br />'
      ret += '<b>Pick Up:</b> '  + date_format(c.pickup_open)   + ' to ' + date_format(c.pickup_close)
      ret
    else 
      ret = '<b>Current Ordering Cycle: ' + DeliveryCycle.current_phase_name(true)   + '</b><br />'
      ret += '<b>Ordering:</b> ' + date_format(c.order_open)    + ' to ' + date_format(c.order_close)    + '<br />'
      ret += '<b>Pick Up:</b> '  + date_format(c.pickup_open)   + ' to ' + date_format(c.pickup_close) 
      ret  
    end
  end
  
  def expand_tree_into_select_field(categories, sel_id)
    returning(String.new) do |html|
      categories.each do |category|
        html << %{<option value="#{ category.id }"}
        html << %{ selected='selected' } if category.id == sel_id 
        html << %{>#{ '&nbsp;&nbsp;&nbsp;' * category.ancestors.size }#{ category.name }</option>}
        html << expand_tree_into_select_field(category.children.sort { |x,y| x.name <=> y.name }, sel_id) if category.children.size > 0
      end
    end
  end
  
  def categories_ul(siblings)
    if siblings.size > 0
      ret = '<ul>'
      siblings.collect do |sibling|
        ret += '<li>' + link_to(sibling.name, admin_category_path(sibling))
        ret += ' (' + link_to('Delete', admin_category_path(sibling), :method => :delete) + ')' 
        ret += categories_ul(sibling.children) if sibling.children.size > 0
        ret += '</li>'
      end
      ret += '</ul>'
    end
    ret
  end
  
  def products_by_category_ul(siblings)
    ret = ''
    siblings.each do |cat|
      ret += '<h4>' + cat[:name] + '</h4>'
      ret += '<ul>' 
      cat[:products].each do |prod|
        ret += '<li><div><p>' + prod.account.name + '<br />'
        ret += prod.title + '<br />'
        ret += prod.description + '</p></div></li>'
      end
      ret += '</ul>'
      ret += products_by_category_ul(cat[:children])
    end
    ret
  end
  
  def category_facets(siblings, facets, search, first=false)
    if siblings.size > 0 
      ret = '<ul class="facets">'
      siblings.sort {|c1,c2| c1.name <=> c2.name }.collect do |sibling|
        next if facets[:categories][sibling.id] == 0
        ret += '<li>'
        ret += link_to "#{sibling.name} (#{facets[:categories][sibling.id]})", products_url(:search => search.conditions.merge(:category_id_equals_any => sibling.descendants.map { |d| d.id }))
        ret += category_facets(sibling.children, facets, search) if sibling.children.size > 0 
        ret += '</li>'
      end
      ret += "<li>#{link_to "Any Category", products_url(:search => search.conditions.reject{ |k,v| k == :category_id_equals_any })}</li>" if first
      ret += '</ul>'
    end
    ret
  end
  
  def make_title(search_params)
    ret = (search_params[:available_orderables_id_greater_than] ? 'Currently available products ' : 'All products ')
    ret += "from #{Account.find(search_params[:account_id_equals]).producer_name} " if search_params[:account_id_equals]
    ret += "in category #{Category.find(search_params[:category_id_equals]).name} " if search_params[:category_id_equals]
    ret
  end
  
  def state_select 
    [ 	
    	['Select a State', nil],
    	['Alabama', 'AL'], 
    	['Alaska', 'AK'],
    	['Arizona', 'AZ'],
    	['Arkansas', 'AR'], 
    	['California', 'CA'], 
    	['Colorado', 'CO'], 
    	['Connecticut', 'CT'], 
    	['Delaware', 'DE'], 
    	['District Of Columbia', 'DC'], 
    	['Florida', 'FL'],
    	['Georgia', 'GA'],
    	['Hawaii', 'HI'], 
    	['Idaho', 'ID'], 
    	['Illinois', 'IL'], 
    	['Indiana', 'IN'], 
    	['Iowa', 'IA'], 
    	['Kansas', 'KS'], 
    	['Kentucky', 'KY'], 
    	['Louisiana', 'LA'], 
    	['Maine', 'ME'], 
    	['Maryland', 'MD'], 
    	['Massachusetts', 'MA'], 
    	['Michigan', 'MI'], 
    	['Minnesota', 'MN'],
    	['Mississippi', 'MS'], 
    	['Missouri', 'MO'], 
    	['Montana', 'MT'], 
    	['Nebraska', 'NE'], 
    	['Nevada', 'NV'], 
    	['New Hampshire', 'NH'], 
    	['New Jersey', 'NJ'], 
    	['New Mexico', 'NM'], 
    	['New York', 'NY'], 
    	['North Carolina', 'NC'], 
    	['North Dakota', 'ND'], 
    	['Ohio', 'OH'], 
    	['Oklahoma', 'OK'], 
    	['Oregon', 'OR'], 
    	['Pennsylvania', 'PA'], 
    	['Rhode Island', 'RI'], 
    	['South Carolina', 'SC'], 
    	['South Dakota', 'SD'], 
    	['Tennessee', 'TN'], 
    	['Texas', 'TX'], 
    	['Utah', 'UT'], 
    	['Vermont', 'VT'], 
    	['Virginia', 'VA'], 
    	['Washington', 'WA'], 
    	['West Virginia', 'WV'], 
    	['Wisconsin', 'WI'], 
    	['Wyoming', 'WY']]
  end
  
  def is_admin
    @current_user and @current_user.admin
  end
  
  def as_money(q) 
    format("$%.2f", q)
  end 
end
