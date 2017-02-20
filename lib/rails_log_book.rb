require 'active_record'
require 'request_store'
require 'log_book/configuration'
require 'log_book/squash_records'
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

    def without_recording
      recording_was_enabled = recording_enabled
      disable_recording
      yield
    ensure
      enable_recording unless recording_was_enabled
    end

    def record_as(author)
      prev_author = LogBook.store[:author]
      LogBook.store[:author] = author
      yield
    ensure
      LogBook.store[:author] = prev_author
    end

    def with_record_squashing
      yield
      squash_records if record_squashing_enabled
    end

    def recording_enabled
      LogBook.store.fetch(:recording_enabled, false)
    end

    def record_squashing_enabled
      LogBook.store.fetch(:record_squashing, LogBook.config.record_squashing)
    end

    def disable_recording
      LogBook.recording_enabled = false
    end

    def enable_recording
      LogBook.recording_enabled = true
    end

    def recording_enabled=(val)
      LogBook.store[:recording_enabled] = val
    end

    def squash_records
      return if LogBook.store[:request_uuid].nil?
      records = LogBook::Record.where(request_uuid: LogBook.store[:request_uuid])
      return if records.empty?
      LogBook::SquashRecords.new(records).call
    end
  end
end
