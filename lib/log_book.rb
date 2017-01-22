require 'active_record'
require 'request_store'
require 'log_book/record'
require 'log_book/version'

module LogBook
  def self.log_book_store
    RequestStore.store[:log_book] ||= {}
  end
end
