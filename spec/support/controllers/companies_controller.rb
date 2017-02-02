class CompaniesController < ActionController::Base
  include LogBook::ControllerRecord

  def create
    company = Company.create(company_params)
    render json: company.to_json
  end

  private

  def company_params
    params.require(:company).permit(:name, users_attributes: [:email, :name])
  end

  def current_user
    User.find(session[:user_id])
  end
end
