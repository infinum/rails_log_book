require 'active_record'
require 'active_support/current_attributes'
require 'dry-configurable'

require 'log_book/configuration'
require 'log_book/store'
require 'log_book/save_records'
require 'log_book/record'
require 'log_book/recorder'
require 'log_book/controller_record'
require 'log_book/version'
require 'log_book/railtie'

module LogBook
  class << self
    def with_recording
      recording_was_disabled = recording_enabled
      enable_recording
      LogBook::Store.records = Set.new

      yield

      LogBook::SaveRecords.call
    ensure
      disable_recording unless recording_was_disabled
    end

    def record_as(author)
      prev_author = LogBook::Store.author
      LogBook::Store.author = author
      yield
    ensure
      LogBook::Store.author = prev_author
    end

    def record_action(action)
      prev_action = LogBook::Store.action
      LogBook::Store.action = action
      yield
    ensure
      LogBook::Store.action = prev_action
    end

    def recording_enabled
      LogBook::Store.recording_enabled || LogBook.config.recording_enabled
    end

    def record_squashing_enabled
      LogBook::Store.record_squashing || LogBook.config.record_squashing
    end

    def disable_recording
      LogBook::Store.recording_enabled = false
    end

    def enable_recording
      LogBook::Store.recording_enabled = true
    end

    def action=(val)
      LogBook::Store.action = val
    end
  end
end
