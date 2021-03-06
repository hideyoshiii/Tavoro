class InvitationsController < ApplicationController

  def invite  
    @invitation = Invitation.new  

    @invitations = Invitation.where(user_id: current_user.id).order(created_at: "DESC")
    @invitations_true = @invitations.where(used: true)
  end

  def invitation
  	@invitation = Invitation.find_by(code: params[:id], used: false)
  end

  def create
  	loop do
      @code = SecureRandom.hex(6)
      break unless Invitation.where(code: @code).exists?
    end
    @invitation = Invitation.new(user_id: current_user.id, code: @code)
    if @invitation.save
    	redirect_back(fallback_location: root_path)
    else
    	redirect_back(fallback_location: root_path)
    end
  end

  def destroy
    
  end
  
end