# -*- encoding : utf-8 -*-

class Mailer

  def self.delivery_method
    @delivery_method ||= {:type => :sendmail, :options => {} }
  end
  
  def self.credentials
    @credentials ||= {:from => 'ondrej@bartas.cz', :subject => "Password reset", :body => "Someone hopefully you, requested password rest"}
  end
  
  def self.send_mail args = {}
    mail = Mail.new do
      from     Mailer.credentials[:from]
      to       args[:to]
      subject  Mailer.credentials[:subject]
      
      text_part do
        body Mailer.credentials[:body]+'\n'+args[:link]
      end
      
      html_part do
        content_type 'text/html; charset=UTF-8'
        body Mailer.credentials[:body].gsub(/\n/, '<br />')+"<br /><a href='#{args[:link]}'>#{args[:link]}</a>"
      end
    end
    mail.delivery_method Mailer.delivery_method[:type], Mailer.delivery_method[:options] 
    mail.deliver if ENV['RACK_ENV'] != "test"
  end
  
end