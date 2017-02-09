class CompaniesController < ActionController::Base
  include LogBook::ControllerRecord

  def create
    company = Company.create(company_params)
    render json: company.to_json
  end

  private

  def company_params
    params.require(:company).permit(
      :name, users_attributes: [:email, :name], company_info_attributes: [:address, :bio]
    )
  end

  def current_author
    User.find(session[:user_id])
  end
end
