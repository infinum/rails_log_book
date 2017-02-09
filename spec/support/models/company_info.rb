class CompanyInfo < ActiveRecord::Base
  include LogBook::Recorder

  has_log_book_records parent: :company

  belongs_to :company
end
