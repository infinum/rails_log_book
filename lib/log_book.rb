require 'active_record'
require 'request_store'
require 'log_book/configuration'
require 'log_book/record'
require 'log_book/recorder'
require 'log_book/controller_record'
require 'log_book/version'

module LogBook
  class << self
    def store
      RequestStore.store[:log_book] ||= {}
    end

    def with_recording
      recording_was_disabled = recording_enabled
      enable_recording
      yield
    ensure
      disable_recording unless recording_was_disabled
    end

    def record_as(author)
      LogBook.store[:author] = author
      yield
    end

    def recording_enabled
      LogBook.store.fetch('recording_enabled', false)
    end

    def disable_recording
      LogBook.recording_enabled = false
    end

    def enable_recording
      LogBook.recording_enabled = true
    end

    def recording_enabled=(val)
      LogBook.store['recording_enabled'] = val
    end
  end
end
