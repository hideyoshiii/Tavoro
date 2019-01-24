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
  end
end
