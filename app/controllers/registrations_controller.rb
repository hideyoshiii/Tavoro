class RegistrationsController < Devise::RegistrationsController
  after_action :follow_tavore, only: [:create]

  protected
 
    def update_resource(resource, params)
      return super if params["password"]&.present?
      resource.update_without_password(params.except("current_password"))
    end

    def after_update_path_for(resource)
      "/#{resource.username}"
    end

    def follow_tavore
      @tavore = User.find_by(username: "tavore")
      current_user.follow!(@tavore)
    end

end
