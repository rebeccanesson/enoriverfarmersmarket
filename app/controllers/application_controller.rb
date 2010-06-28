# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user, :current_delivery_cycle
  before_filter :load_session_variables

  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
    
    def current_delivery_cycle
      return @current_delivery_cycle if defined?(@current_delivery_cycle)
      @current_delivery_cycle = DeliveryCycle.current
      unless @current_delivery_cycle
        orderables = Orderable.find(:all, :conditions => "status='Available' or status='In Cart'")
        orderables.each do |o| 
          o.status = 'Closed'
          o.save
        end 
        return nil
      end
      if @current_delivery_cycle.is_after_order
        @current_delivery_cycle.orderables.available.each do |o|
          o.status = 'Closed'
          o.save
        end
        @current_delivery_cycle.orderables.in_cart.each do |o|
          o.status = 'Ordered'
          o.save
        end
      end
      # not sure if this should be done because it erases the record of what was ordered....
      # if @current_delivery_cycle.is_past
      #   @current_delivery_cycle.orderables.ordered.each do |o|
      #     o.status = 'Closed'
      #     o.save
      #   end
      # end
    end
    
    def require_ordering_is_open
      current_delivery_cycle
      logger.debug("#{@current_delivery_cycle} #{@current_delivery_cycle.is_order}")
      unless @current_delivery_cycle and @current_delivery_cycle.is_order
        respond_to do |format|
          format.html { 
            flash[:notice] = "This action can only be taken when ordering is open."
            redirect_to products_url(@user)
          }
          format.js { 
            render :action => :error
          }
        end
      end
    end
    
    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to user_url(current_user)
        return false
      end
    end
      
    def require_admin
      unless current_user and current_user.admin
        flash[:notice] = "You must have administrator privileges to access this page"
        if current_user
          redirect_to user_url(current_user)
        else
          redirect_to new_user_session_url
        end
        return false
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    
    def load_session_variables
      current_user_session
      current_user
      current_delivery_cycle
    end
    
    def load_sidebar_variables
      @sidebar_producers = Account.find(:all, :order => "producer_name ASC")
    end
end
