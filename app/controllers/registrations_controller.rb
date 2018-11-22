class RegistrationsController < Devise::RegistrationsController
  after_action :follow_tavore, only: [:create]

  protected
 
  def update_resource(resource, params)
    resource.update_without_current_password(params)
  end

  def after_update_path_for(resource)
    "/users/edit"
  end

  def follow_tavore
      @tavore = User.find_by(username: "tavore")
      current_user.follow!(@tavore)
      if params[:invitation_id].present?
        @invitation = Invitation.find(params[:invitation_id].to_i)
        if @invitation
          @invitation.used = true
          @invitation.invited_user_id = current_user.id
          @invitation.save
          @invitation_user = User.find(@invitation.user_id)
          if @invitation_user
            unless @invitation_user == @tavore
              if current_user.follow!(@invitation_user)
                Notification.create(user_id: @invitation_user.id,notified_by_id: current_user.id,notified_type: 'follow')
              end
            end
          end
        end
      end
  end
end
