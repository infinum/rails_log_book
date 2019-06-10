module LogBook
  module ControllerRecord
    extend ActiveSupport::Concern

    included do
      around_action :enable_recording
    end

    def enable_recording
      LogBook::Store.action = "#{controller_name}##{action_name}"
      LogBook::Store.author = current_author
      LogBook::Store.request_uuid = try(:request).try(:uuid) || SecureRandom.hex
      LogBook::Store.records = Set.new
      LogBook.enable_recording

      yield

      LogBook::SaveRecords.call
    end

    def current_author
      raise NotImplementedError unless respond_to?(LogBook.config.author_method, true)

      send(LogBook.config.author_method)
    end
  end
end
