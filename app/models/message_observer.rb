class MessageObserver < ActiveRecord::Observer
	def after_create(message)
		Notifications.deliver_new_message(message,APP_URL) if message.recipient.profile.email == true
	end
end
