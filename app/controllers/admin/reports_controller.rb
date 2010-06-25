class Admin::ReportsController < Admin::AdminController
  
  def invoices_by_customer
    @delivery_cycle = current_delivery_cycle
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
    @delivery_cycle = current_delivery_cycle
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

end