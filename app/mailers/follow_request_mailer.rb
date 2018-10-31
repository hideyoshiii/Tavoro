class FollowRequestMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.user_welcome_mail.subject
  #
  def request_send_mail(user, user_requested)
    attachments.inline['tavore_logo_01.png'] = File.read('app/assets/images/tavore_logo_01.png')
    @user = user
    @user_requested = user_requested
	  mail(to: @user.email, subject: "#{@user_requested.name}さんからフォローリクエストが届きました")
  end

  def request_approved_mail(user, user_approved)
    attachments.inline['tavore_logo_01.png'] = File.read('app/assets/images/tavore_logo_01.png')
    @user = user
    @user_approved = user_approved
    mail(to: @user.email, subject: "#{@user_approved.name}さんへのフォローリクエストが承認されました")
  end

end