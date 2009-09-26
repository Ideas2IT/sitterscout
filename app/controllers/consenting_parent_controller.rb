class ConsentingParentController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :direct_to_current_state
 layout 'new_design'
  def index
    if request.post?
        @sitter = Sitter.find_by_birthday_and_email(params[:sitter]["birthday(1i)"] + "-" + params[:sitter]["birthday(2i)"] + "-" + params[:sitter]["birthday(3i)"], params[:sitter][:email])
        unless @sitter.nil?
          @consenting_parent= @sitter.consenting_parent
          if @consenting_parent
                if @sitter
                  @consenting_parent.update_attributes(params[:consenting_parent])
                  flash[:notice] = "Your preferences have been updated!"
                  #flash.discard
                      if @consenting_parent.approved
                        Sitter.find_by_email(params[:sitter][:email]).activate
                        #@consenting_parent.underaged_sitter.save
                        Notifications.deliver_parental_consent_given(@consenting_parent, @sitter)
                      elsif @consenting_parent.approved == false
                        Notifications.deliver_parental_consent_declined(@consenting_parent, @sitter)
                      end
                end
          else
            flash[:error] = "We couldn't find your child with the information provided. Please try again."
            ##flash.discard
            return
          end
        else
          flash[:error] = "We couldn't find your child with the information provided. Please try again."
          ##flash.discard
          return
        end
      
    end    
  end

end
