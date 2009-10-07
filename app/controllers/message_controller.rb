class MessageController < ApplicationController
  
  include ActionView::Helpers::TextHelper
  
	before_filter :login_required

  layout "new_design"
	
	def compose
		@sender = current_user
		@recipient = ""

	end

	# To reply to a message, the message must exist and have been sent to this user. This user can't have been blocked by the recipient.
	def reply
		if params[:message_id].nil?
		  flash[:error] = "Sorry, we couldn't located the message you're looking for."
      redirect_to :back
			return
		end
		

		@message = Message.find(:first, :conditions => ["id = ? AND recipient_id = ?", params[:message_id], current_user.id])

		if @message.nil?
		  flash[:error] = "Sorry, we couldn't located the message you're looking for."
			redirect_to :back
			return
		end

		@sender = current_user
		@recipient = @message.sender

		@message.subject.insert(0, "Re: ") unless !@message.subject.match(/^Re:\s/).nil?

		@message.body.insert(0, "\n\n\n--------- Original Message ---------\n")

		render :action => :compose
	end

	# Actually send the message to another member
	def send_message
		begin
			ok = true
			this_message = Message.new()
			this_message.user_id = current_user.id
			this_message.recipient_id = params[:message][:recipient_id]
			this_message.body = params[:message][:body]
			this_message.subject = params[:message][:subject]
			if this_message.save!
        flash[:notice] = "Your message has been sent."
		  else
		    redirect_to :back
		    return
		  end
			#flash.discard
     rescue ActiveRecord::RecordInvalid
       flash[:notice] = $!.message
		   redirect_to :back
		   return
     end

	  # if params[:from_messages]
	 #      redirect_to url_for('/messages')
	 #   elsif params[:from_profile]
	 #      redirect_to url_for( :controller => :profile, :action => :show, :nickname => @recipient.nickname )
	 #   else
	 #      redirect_to :action => :list
	 #   end
	 flash[:notice] = "Message sent."
	 #flash.discard
	 if current_user.is_a?Parent
	   redirect_to inbox_parent_path(current_user)
   else
     redirect_to inbox_sitter_path(current_user)
   end
	 
		return
	end


	# read a message
	def show
		msg_type = params[:type]||"received"
		case msg_type
		when "sent"
		 @message = current_user.sent_messages.find(:first, :conditions => {:id => params[:id]}, :include => [{:recipient => :photo}])
		else
			@message = current_user.received_messages.find(:first, :conditions => {:id => params[:id]}, :include => [{:sender => :photo}])
			if @message.status == "new"
				@message.status = "read"
				@message.save
			end
		end

		render :partial => "message",
			:locals => {
				:message => @message
			}
	end

	# delete a message
	# deletions don't really delete until both the sender and recipient have both deleted. 
	# The actual destruction is handled by a callback Message#after_save
	def delete
		response = {:success => true}

		if params[:message_ids].nil?
			response[:success] = false
		else
			response[:success] = Message.update_all("sender_deleted = 1", ["user_id = ? AND id IN (?)", current_user.id, params[:message_ids]])
			response[:success] = true && Message.update_all("recipient_deleted = 1", ["recipient_id = ? AND id IN (?)", current_user.id, params[:message_ids]])
		end

		respond_to do |wants|
			wants.js {
				render :json => response
				return
			}
			wants.html {
				return
			}
		end
	end

	# report a concern
	def report
		response = {:success => false}

		if !params[:concern].nil?
			@message = Message.find(params[:concern][:message_id])
			if !@message.nil?
				@concern = MessageConcern.create(params[:concern])
				@concern.user_id = current_user.id
				@concern.message_id = @message.id
				@concern.subject = "Reported Message"
				@concern.body = params[:concern][:body]

				if @concern.save
					response[:success] = true
				end
			end
		end

		respond_to do |wants|
			wants.js {
				render :json => response
				return
			}
			wants.html {
				return
			}
		end
	end

	def list
    return_data = {} 
    messages = current_user.received_messages.find(:all)
    return_data[:messages] = messages.collect{|m| {
                  :id => m.id,
                  :nickname => m.sender.profile.full_name,
                  :subject => truncate(m.subject,15),
                  :created_at => m.created_at.strftime('%m/%d/%Y'),
                  :status => m.status,
                  :type => "received"
                }}
    render :json => return_data.to_json
  end
  
  # contact history between this user and another
	def history
		@partner = User.find_by_nickname(params[:nickname], :include => [:lead_photo, {:profile => :profile_text}])

		if @partner.nil?
			flash[:error] = "There was a problem receiving the nickname of the member."
			redirect_to :action => :list
		end

		@received_messages = current_user.received_messages.find_all_by_user_id(@partner.id, :order => "messages.created_at DESC")
		@sent_messages = current_user.sent_messages.find_all_by_recipient_id(@partner.id, :order => "messages.created_at DESC")
		@received_winks = current_user.received_winks.find_all_by_user_id(@partner.id, :order => "winks.created_at DESC")
		@sent_winks = current_user.sent_winks.find_all_by_recipient_user_id(@partner.id, :order => "winks.created_at DESC")
		@favorites = current_user.favorite_users.find_all_by_favorite_user_id(@partner.id, :order => "favorites.created_at DESC")
	end

	# This gets hairy. We need to get the latest communication across a number of models and then page over those.
	def connections
		@page = (params[:page]||1).to_i
		@page_size = 12
		@type = params[:type]||""
		@wink_type = params[:wink_type]||"received"
		@sort = params[:sort]||"most_recent"

		blocked_user_ids = current_user.blocked_user_ids + [-1]

		filter_sql = " (users.deleted_at is null OR users.deleted_at > ?) AND users.id NOT IN (?)"
		filter_args = [Time.now,blocked_user_ids]
		case @type
			when "winks"
				filter_sql = filter_sql + " AND (users.id IN (?))"
				case @wink_type
					when "sent"
						sent_wink_user_ids = current_user.sent_wink_user_ids + [-1]
						filter_args = filter_args + [sent_wink_user_ids]					
					when "received"
						received_wink_user_ids = current_user.received_wink_user_ids + [-1]
						filter_args = filter_args + [received_wink_user_ids]
						Wink.update_all "status = 'read'", ["recipient_user_id = ? AND status = 'new'", current_user.id]
				end
			when "favorites"
				favorite_user_ids = current_user.favorite_user_ids + [-1]
				filter_sql = filter_sql + " AND (users.id IN (?))"
				filter_args = filter_args + [favorite_user_ids]
		end

		received_messages = current_user.received_messages.find(:all, :include => [:sender => [:lead_photo, :profile]], :order => "messages.created_at DESC", :group => 'messages.user_id', :conditions => [filter_sql + " AND recipient_deleted <> 1"] + filter_args)
		sent_messages = current_user.sent_messages.find(:all, :include => [:recipient => [:lead_photo, :profile]], :order => "messages.created_at DESC", :group => 'messages.recipient_id', :conditions => [filter_sql + " AND sender_deleted <> 1"] + filter_args)
		received_winks = current_user.received_winks.find(:all, :include => [:sender => [:lead_photo, :profile]], :order => "winks.created_at DESC", :group => 'winks.user_id', :conditions => [filter_sql + " AND recipient_deleted <> 1"] + filter_args)
		sent_winks = current_user.sent_winks.find(:all, :include => [:recipient => [:lead_photo, :profile]], :order => "winks.created_at DESC", :group => 'winks.recipient_user_id', :conditions => [filter_sql + " AND sender_deleted <> 1"] + filter_args)
		sent_favorites = current_user.favorite_users.find(:all, :include => [:favorited => [:lead_photo, :profile]], :order => "favorites.created_at DESC", :group => 'favorites.favorite_user_id', :conditions => [filter_sql] + filter_args)
		
		# Prepare our connections abstraction array.
		connections = []

		# Loop over each of our different object types and push them onto the connections array with similar properties.
		received_messages.each { |i|
			connections.push({:type => i.class.name, :sent => false, :obj => i, :user => i.sender})
		}
		sent_messages.each { |i|
			connections.push({:type => i.class.name, :sent => true, :obj => i, :user => i.recipient})
		}
		received_winks.each { |i|
			connections.push({:type => i.class.name, :sent => false, :obj => i, :user => i.sender})
		}
		sent_winks.each { |i|
			connections.push({:type => i.class.name, :sent => true, :obj => i, :user => i.recipient})
		}
		sent_favorites.each { |i|
			connections.push({:type => i.class.name, :sent => false, :obj => i, :user => i.favorited})
		}

		# Sort our connections by when they were created, sorts ascending by default so we have to multiply the comparison by -1 to reverse it.
		# We have to sort by date first, then by user choice after the array has been unique'd to make "Your Turn/Their Turn" not flip back and forth based on sorting options.
		connections.sort! { |a, b|
			((a[:obj].created_at <=> b[:obj].created_at) * -1)
		}

		# Prepare our unique user id's hash.
		user_ids = {}
		unique_connections = []

		# We only want the most recent action for each user we've interacted with to show.
		connections.each_index { |i|
			if !connections[i][:user].nil? && user_ids[connections[i][:user].id].nil?
		    unless connections[i][:user].is_admin?
				  unique_connections.push(connections[i])
				  user_ids[connections[i][:user].id] = true
			  end
			end
		}

		@connections = unique_connections

		# Sort our connections based on user choice.
		@connections.sort! { |a, b|
			case @sort
				when "nickname"
					((a[:user].nickname.upcase <=> b[:user].nickname.upcase))
				when "your_turn"
					# This is messy, TrueClass/FalseClass do not have a <=> method...
					((a[:sent].to_s <=> b[:sent].to_s))
				when "their_turn"
					# This is messy, TrueClass/FalseClass do not have a <=> method...
					((a[:sent].to_s <=> b[:sent].to_s) * -1)
				else
					0
			end
		}

		@connections_size = @connections.size

		@connections = @connections.paginate(@page, @page_size)
	end

	# Get the user's saved responses
	def templates
		@message_templates = current_user.message_templates
	end
	
	# show form for edit message template
	def template_form
	
			@message_templates = current_user.message_templates
	
		if !params[:id].blank?
			@message_template = MessageTemplate.find(params[:id])
			if @message_template.nil? || @message_template.user.id != current_user.id
				redirect_to :action => :templates
				return
			end
		else
			 @message_template = MessageTemplate.new
		end
	end

	def save_template
		if !params[:message_template][:id].blank?
			@message_template = MessageTemplate.find(params[:message_template][:id])
			if @message_template.nil? || @message_template.user.id != current_user.id
				redirect_to :action => :templates
				return
			end
		else
			 @message_template = MessageTemplate.new
		end

		@message_template.update_attributes(params[:message_template])

		begin
			@message_template.user_id = current_user.id
			@message_template.save!
			flash[:notice] = "Saved Message saved successfully"
			#flash.discard
			redirect_to :action => :templates
			return
		rescue ActiveRecord::RecordInvalid
			flash[:notice] = $!.message
			#flash.discard
			redirect_to :action => :templates
		end

	end

	def delete_template
		begin
			@message_template = MessageTemplate.find(params[:id])
			if @message_template.nil? || @message_template.user.id != current_user.id
				redirect_to :action => :templates
				return
			end
			@message_template.destroy
			flash[:notice] = "Saved Message deleted successfully"
			#flash.discard
		rescue
			flash[:notice] = "There was a problem deleting this saved message"
			#flash.discard
		end

		redirect_to :action => :templates
		return
	end
	
end
