class Company < ActiveRecord::Base
  include LogBook::Recorder

  has_log_book_records

  has_many :users, class_name: 'UserWithAll'
  has_one :company_info
  accepts_nested_attributes_for :users
  accepts_nested_attributes_for :company_info
end
