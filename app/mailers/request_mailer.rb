class RequestMailerError < StandardError; end

class RequestMailer < ActionMailer::Base
  layout 'request_mailer'
  ALWAYS_SEND_TO_EMAILS = ["emails@#{ENV['MAIL_DOMAIN']}"]

  def self.send_as_html(mail, *args)
    args = args.unshift(true)
    email = self.send(mail.to_s, *args).deliver
    #email.set_content_type("text/html")
    #self.deliver(email)
  end

  def self.preview(mail, *args)
    args = args.unshift(false)
    preview = self.send(mail.to_s, *args)
    preview.set_content_type('text/html')
    return preview.encoded
  end

  def self.create_event_for(mail_params)
    # to, from, subject, content, employee_id
    email = Email.new(:to => mail_params[:to], :from => mail_params[:from], :subject => mail_params[:subject], :content => mail_params[:content])
    employee = Employee.current_employee
    employee_id = employee ? employee.id : 1
    email.employee_id = employee_id
    email.save

    email.events.create(:description => "subject: #{email.subject} // from: #{email.from} // to: #{email.to}")
  end

  def note_submitted(if_log, user_note)
    emails = Employee.list_popv_admin_emails
    emails << user_note.submitting_user.email
    emails_comma_separated = emails.join(', ') || "maisa.engineers@gmail.com"

    @user_note = user_note
    subject    = "[#{ENV['DEPLOY_SITE_NAME']} Material Tracker] POPV User Note Submitted"
    #@body       = {:user_note => user_note}
    recipients =  emails || "maisa.engineers@gmail.com"
    bcc        = ALWAYS_SEND_TO_EMAILS
    from       = "no-reply@#{ENV['MAIL_DOMAIN']}"
    if if_log
      RequestMailer.create_event_for(to: emails_comma_separated, from: from, subject: subject,content: RequestMailer.preview('note_submitted', user_note))
    end
    mail(from: from,to: recipients,subject: subject,bcc: bcc)
  end

  def note_reply(if_log, user_note)
    @user_note = user_note
    subject    = "[#{ENV['DEPLOY_SITE_NAME']} Material Tracker] POPV User Note ##{user_note.id} Updated"
    #@body       = {:user_note => user_note}
    recipients = "#{user_note.submitting_user.email}"
    bcc        = ALWAYS_SEND_TO_EMAILS
    from       = "no-reply@#{ENV['MAIL_DOMAIN']}"
    #@headers    = {}

    if if_log
      RequestMailer.create_event_for(:to => recipients, :from => from, :subject => subject,
                                     :content => RequestMailer.preview('note_reply', user_note))
    end
    mail(from: from,to: recipients,subject: subject,bcc: bcc)
  end

  # Sends the purchase order reminders in one email per address, some with multiple PO
  # reminders in them.
  def order_reminders(if_log, recipients, reminders)
    subject    = "[#{ENV['DEPLOY_SITE_NAME']} Material Tracker] Purchase Order Reminders"
    #@body       = {:reminders => reminders}
    @reminders = reminders
    recipients = recipients # bp.carson.fifth@gmail.com
    bcc        = ALWAYS_SEND_TO_EMAILS
    from       = "no-reply@#{ENV['MAIL_DOMAIN']}"
    #@headers    = {}
    #@content_type = "text/html"

    if if_log
      RequestMailer.create_event_for(to: recipients, from: @from, subject: subject,
                                     content: RequestMailer.preview('order_reminders', recipients, reminders))
    end
    mail(from: from,to: recipients,subject: subject,bcc: bcc)
  end

  def order_for_fifth(if_log, order, params)
    params[:line_items] ||= {}

    # params[:line_items] can be a Hash or an Array
    if params[:line_items].is_a?(Hash)
      params[:line_items] = params[:line_items].keys.sort
    else
      params[:line_items] = params[:line_items].sort
    end

    @ordered_line_items = OrderedLineItem.find(params[:line_items])
    @ordered_line_items = @ordered_line_items.sort { |a, b| a.line_item_no <=> b.line_item_no }

    subject    = "[#{ENV['DEPLOY_SITE_NAME']} Material Tracker] PO ##{order.po_no}"
    #@body       = { :order => order, :params => params, :ordered_line_items => @ordered_line_items }
    @order = order
    @params = params

    recipients = params[:email] # bp.carson.fifth@gmail.com
    bcc        = ALWAYS_SEND_TO_EMAILS
    from       = params[:from] || "no-reply@#{ENV['MAIL_DOMAIN']}"
    #@headers    = {}

    if if_log
      RequestMailer.create_event_for(to: recipients, from: from, subject: subject,
                                     content: RequestMailer.preview('order_for_fifth', order, params))
    end
    mail(from: from,to: recipients,subject: subject,bcc: bcc)
  end

  def orders_for_fifth(if_log, orders, params)
    params[:line_items] ||= {}
    orders.each do |order|
      params[:line_items][order.id.to_s] ||= {}
      params[:line_items][order.id.to_s] = params[:line_items][order.id.to_s].keys if params[:line_items][order.id.to_s].is_a?(Hash)

      params[:line_items][order.id.to_s] = params[:line_items][order.id.to_s].sort
      params[:line_items][order.id.to_s] = OrderedLineItem.find(params[:line_items][order.id.to_s])
      params[:line_items][order.id.to_s] = params[:line_items][order.id.to_s].sort { |a, b| a.line_item_no <=> b.line_item_no }
    end
    subject    = "[#{ENV['DEPLOY_SITE_NAME']} Material Tracker] POs: " + orders.map(&:po_no).join(', ')
    #@body       = { :orders => orders, :params => params }
    @orders = orders
    @params = params
    recipients = params[:email] # bp.carson.fifth@gmail.
    bcc        = ALWAYS_SEND_TO_EMAILS
    from       = params[:from] || "no-reply@#{ENV['MAIL_DOMAIN']}"
    #@headers    = {}

    if if_log
      RequestMailer.create_event_for(to: recipients, from: from, subject: subject,
                                     content: RequestMailer.preview('orders_for_fifth', orders, params))
    end
    mail(from: from,to: recipients,subject: subject,bcc: bcc)
  end

  def quote_for_vendor(if_log, request, vendor_or_planner,quote, params)

    subject    = "[#{ENV['DEPLOY_SITE_NAME']} Material Tracker] Request for Quote - Tracking #: #{request.tracking}"
    #@body       = {:quote => quote, :request => request, :vendor => vendor_or_planner, :planner => vendor_or_planner, :params => params,
    #:is_vendor => (vendor_or_planner.class == Vendor), :is_planner => (vendor_or_planner.class == Employee) }
    @quote = quote
    @request = request
    @vendor = vendor_or_planner
    @planner = vendor_or_planner
    @params = params
    @is_vendor = (vendor_or_planner.class == Vendor)
    @is_planner = (vendor_or_planner.class == Employee)
    recipients = params[:email] || vendor_or_planner.email
    bcc        = ALWAYS_SEND_TO_EMAILS
    from       = params[:from] || "no-reply@#{ENV['MAIL_DOMAIN']}"
    #@headers    = {}

    # Create the quote if it doesn't already exist
    if if_log && vendor_or_planner.is_a?(Vendor)
      Quote.find_or_create(request, vendor_or_planner)
    end

    if if_log
      RequestMailer.create_event_for(to: recipients, from: from, subject: subject,
                                     content: RequestMailer.preview('quote_for_vendor', request, vendor_or_planner, quote, params))
    end
    mail(from: from,to: recipients,subject: subject,bcc: bcc)
  end

  def quote_change(if_log, quote, email, from = "no-reply@#{ENV['MAIL_DOMAIN']}")
    subject    = "[#{ENV['DEPLOY_SITE_NAME']} Mataerial Tracker] Quote ##{quote.material_request.tracking} has been updated (#{quote.vendor.name})"
    #@body       = { :quote => quote, :material_request => quote.material_request, :vendor => quote.vendor }
    @quote = quote
    @material_request = quote.material_request
    @vendor = quote.vendor
    recipients = email
    bcc        = ALWAYS_SEND_TO_EMAILS
    from       = from
    #@headers    = {}
    mail(from: from,to: recipients,subject: subject,bcc: bcc)
  end

  def request_for_purchaser(if_log, request, params)
    subject    = "[#{ENV['DEPLOY_SITE_NAME']} Material Tracker] Request ##{request.tracking}"
    #@body       = { :request => request, :params => params }
    @request = request
    @params  = params
    recipients = params[:email]
    bcc        = ALWAYS_SEND_TO_EMAILS
    from       = params[:from] || "no-reply@#{ENV['MAIL_DOMAIN']}"
    #@headers    = {}

    if if_log
      RequestMailer.create_event_for(to: recipients, from: from, subject: subject,
                                     content: RequestMailer.preview('request_for_purchaser', request, params))
    end
    mail(from: from,to: recipients,subject: subject,bcc: bcc)
  end

  def requests_for_planner(if_log, planner, requests)
    return unless planner.email?
    subject    = "[#{ENV['DEPLOY_SITE_NAME']} Material Tracker] Requests Summary for #{Date.today.to_s(:long)}"
    #@body       = { :planner => planner, :requests => requests }
    @planner = planner
    @requests = requests
    recipients = planner.email
    bcc        = ALWAYS_SEND_TO_EMAILS
    from       = params[:from] || "no-reply@#{ENV['MAIL_DOMAIN']}"
    #@headers    = {}

    if if_log
      RequestMailer.create_event_for(to: recipients, from: from, subject: subject,
                                     content: RequestMailer.preview('requests_for_purchaser', planner, requests))
    end
    mail(from: from,to: recipients,subject: subject,bcc: bcc)
  end

  def generic(options)
    subject    = options[:subject] || "[#{ENV['DEPLOY_SITE_NAME']} Material Tracker]"
    #@body       = { :text => options[:body] || "" }
    @text =  options[:body] || ""
    recipients = options[:to]
    bcc        = ALWAYS_SEND_TO_EMAILS
    from       = options[:from] || "no-reply@#{ENV['MAIL_DOMAIN']}"
    #@headers = {}
    mail(from: from,to: recipients,subject: subject,bcc: bcc)
  end

  def popv_reports(email, report)
    report_class = report[:class]
    report_method = report[:method]
    report_options = ActiveSupport::JSON.decode(report[:options])

    @report = Report.interpret_report(report_class, report_method, report_options)

    if @report.is_a?(Report)
      attachment_body = @report.generate
      attachment_title = @report.title
      attachment_content_type = @report.content_type
    else
      raise RequestMailerError, "Could not find a method to generate the report: #{report_class.to_s}##{report_method}"
    end

    body_text = "#{Employee.current_employee.name_and_email} wants to share this report with you. Open the attachment to view the report.<br/><br/><b>Message:</b><br/><br/>#{email[:body]}"

    subject    = email[:subject] || "[#{ENV['DEPLOY_SITE_NAME']} Material Tracker]"
    #@body       = body_text
    recipients = email[:email_to]
    bcc        = ALWAYS_SEND_TO_EMAILS
    from       = "no-reply@#{ENV['MAIL_DOMAIN']}"
    #@content_type = "text/html"
    #@headers = {}

    attachment_body ||= ''
    attachment_title ||= ''
    attachment_content_type ||= 'application/pdf'

=begin
    attachment :filename => attachment_title,
               :content_type => attachment_content_type,
               :body => attachment_body
=end
    #TODO find the report path and read or join that file in rails 3
    attachments[attachment_title] = attachment_body #File.read("#{Rails.root}/public/#{path}")
    mail(from: from,to: recipients,subject: subject,bcc: bcc)  do |format|
      format.text { render :text => body_text }
    end
  end
  def new_ticket(ticket)
    subject    = "[#{ENV['DEPLOY_SITE_NAME']} Material Tracker] New #{ticket.category} Ticket Submitted"
    recipients = ENV['SUPPORT_EMAIL']#support@telaeris.com'
    #@bcc        = ALWAYS_SEND_TO_EMAILS
    from       = "no-reply@#{ENV['MAIL_DOMAIN']}"
    #@content_type = "text/html"

    @ticket = ticket

    mail(from: from,to: recipients ,subject: subject)
  end

  private

  # Takes an Array or String as `emails` and appends `email_to_add` (String) to it
  def add_to_email_list(emails = "", email_to_add = "")
    if emails.class == String
      emails << ", #{email_to_add}"
    elsif emails.class == Array
      emails << email_to_add
    end
    emails
  end
end
