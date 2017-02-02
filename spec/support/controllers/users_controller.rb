class UsersController < ActionController::Base
  include LogBook::ControllerRecord
  override_author_method :current_admin

  def create
    user = User.create(user_params)
    render json: user.to_json
  end

  def register
    user = User.create(user_params)
    render json: user.to_json
  end

  private

  def user_params
    params.require(:user).permit(:email, :name)
  end

  def current_admin
    User.find(session[:user_id])
  end
end
