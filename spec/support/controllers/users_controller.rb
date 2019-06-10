class UsersController < ActionController::Base
  include LogBook::ControllerRecord

  def create
    user = User.create(user_params)
    render json: user.to_json
  end

  def register
    LogBook.action = 'register'
    user = User.create(user_params)
    render json: user.to_json
  end

  def create_core_user
    user = Administrator.new(admin_params)

    user.build_user_type
    user.core_user = user.user_type.build_core_user(core_user_params)
    user.recording_parent = user.core_user

    user.save
    render json: user.to_json
  end

  private

  def user_params
    params.require(:user).permit(:email, :name)
  end

  def admin_params
    params.require(:user).permit(:name)
  end

  def core_user_params
    params.require(:user).permit(:email)
  end

  def current_author
    User.find(session[:user_id])
  end
end
