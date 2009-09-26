class ParentMailer < ActionMailer::Base
    default_url_options[:host] = APP_URL.sub('http://', '')
    include ActionController::UrlWriter
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::SanitizeHelper  

    def send_invitation(user, email)
      content_type "text/html"
        setup_sender_info
        @recipients = "#{email}"
        @subject = "Come join us."
        @sent_on = Time.new
        
        
    end
  
  
    def signup_invitation(email, user, message)
      content_type "text/html"
      setup_sender_info
      @recipients  = "#{email}"
      @subject     = "#{user.login} would like you to join #{AppConfig.community_name}!"
      @sent_on     = Time.now
      @body[:user] = user
      @body[:url]  = user.generate_invite_url    
      @body[:message] = message
    end

    def friendship_request(friendship)
      content_type "text/html"
      setup_sender_info
      @recipients  = "#{friendship.friend.email}"
      @subject     = "#{friendship.user.login} would like to be friends with you on #{AppConfig.community_name}!"
      @sent_on     = Time.now
      @body[:url]  = friendship.generate_url
      @body[:user] = friendship.friend
      @body[:requester] = friendship.user
    end

   
    def signup_notification(user)
    content_type "text/html"      
      setup_email(user)
      @subject    += "Please activate your new #{AppConfig.community_name} account"
      @body[:url]  = "#{APP_URL}/parents/activate/#{user.activation_code}"
    end

    def send_welcome_email(user)
      content_type "text/html"
      setup_email(user)
      @subject += "Welcome to SitterScout!"
    end


   def activation(user)
      content_type "text/html"
      setup_email(user)
      @subject    += "Your #{AppConfig.community_name} account has been activated!"
      @body[:url]  = "#{APP_URL}"
    end

    def reset_password(user)
          content_type "text/html"
      setup_email(user)
      @subject    += "#{AppConfig.community_name} User information"
    end

    def forgot_username(user)
          content_type "text/html"
      setup_email(user)
      @subject    += "#{AppConfig.community_name} User information"
    end


    protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      setup_sender_info
      @subject     = "[#{AppConfig.community_name} registration] "
      @sent_on     = Time.now
      @body[:user] = user
    end

    def setup_sender_info
      @from        = "The #{AppConfig.community_name} Team <#{AppConfig.support_email}>"    
    end

  end
