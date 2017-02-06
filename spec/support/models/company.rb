class Company < ActiveRecord::Base
  include LogBook::Recorder

  has_log_book_records

  has_many :users, class_name: 'UserWithAll'
  accepts_nested_attributes_for :users
end
