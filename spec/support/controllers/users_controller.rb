class UsersController < ActionController::Base
  include LogBook::ControllerRecord

  def create
    user = User.create(user_params)
    render json: user.to_json
  end

  def register
    LogBook.store[:action] = 'register'
    user = User.create(user_params)
    render json: user.to_json
  end

  private

  def user_params
    params.require(:user).permit(:email, :name)
  end

  def current_author
    User.find(session[:user_id])
  end
end
