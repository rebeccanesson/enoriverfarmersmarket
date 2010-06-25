class Admin::ReportsController < Admin::AdminController
  before_filter :load_delivery_cycle, :only => [:invoices_by_customer, :invoices_by_producer]
  
  def invoices_by_customer
    respond_to do |format|
      format.html { 
        @report = AdminInvoicesByCustomerReport.render_html(:delivery_cycle_id=>@delivery_cycle.id)
      }
      format.pdf {
        pdf = AdminInvoicesByCustomerReport.render_pdf(:delivery_cycle_id=>@delivery_cycle.id)
        send_data pdf, :type => "application/pdf", :filename => "invoices_by_customer.pdf"
      }
    end
  end
  
  def invoices_by_producer
    respond_to do |format|
      format.html { 
        @report = AdminInvoicesByProducerReport.render_html(:delivery_cycle_id=>@delivery_cycle.id)
      }
      format.pdf {
        pdf = AdminInvoicesByProducerReport.render_pdf(:delivery_cycle_id=>@delivery_cycle.id)
        send_data pdf, :type => "application/pdf", :filename => "invoices_by_producer.pdf"
      }
    end
  end
  
  def load_delivery_cycle
    @delivery_cycle = current_delivery_cycle
     if !@delivery_cycle
       flash[:notice] = 'Cannot view invoices when there is no current delivery cycle.'
       redirect_to '/admin'
     end
  end

end