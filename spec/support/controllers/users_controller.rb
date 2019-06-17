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
    user = Administrator.create(admin_params)

    user.save
    render json: user.to_json
  end

  private

  def user_params
    params.require(:user).permit(:email, :name)
  end

  def admin_params
    params.require(:user).permit(:name, user_type_attributes: { core_user_attributes: [:id, :email]})
  end

  def current_author
    User.find(session[:user_id])
  end
end
