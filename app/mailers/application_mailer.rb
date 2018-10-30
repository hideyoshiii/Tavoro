class ApplicationMailer < ActionMailer::Base
  default from:     "TAVORE",
          reply_to: "tavore.info@gmail.com"
  layout 'mailer'
end
