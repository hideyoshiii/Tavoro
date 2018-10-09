class WorksController < ApplicationController
  before_action :sign_in_required, only: [:index]

  def home
  end
  def index
  end
end
