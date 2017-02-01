require 'active_record'
require 'request_store'
require 'log_book/configuration'
require 'log_book/record'
require 'log_book/recorder'
require 'log_book/version'

module LogBook
  def self.store
    RequestStore.store[:log_book] ||= {}
  end
end
