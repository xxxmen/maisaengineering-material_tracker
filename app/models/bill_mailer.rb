class BillMailer < ActionMailer::Base
  def self.send_as_html(mail, *args)
    email = self.send("create_" + mail.to_s, *args)
    email.set_content_type("text/html")
    self.deliver(email)
  end

  def quote(bill_id, params)
    @subject    = 'Quote for Bill of Materials'
    @body       = {:bill => Bill.find(bill_id), :notes => params[:notes]}
    @recipients = params[:email]
    @from       = params[:from].blank? ? "no-reply@#{ENV['MAIL_DOMAIN']}" : params[:from]
    @sent_on    = Date.today
    @headers    = {}
  end
end
