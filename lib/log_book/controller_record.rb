module LogBook
  module ControllerRecord
    extend ActiveSupport::Concern

    included do
      before_action :enable_recording
      after_action :save_records
    end

    def enable_recording
      action = "#{controller_name}##{action_name}"
      author = current_author
      request_uuid = try(:request).try(:uuid) || SecureRandom.hex
      LogBook::Store.tree = LogBook::Tree.new(action: action, author: author, request_uuid: request_uuid)
      LogBook.enable_recording
    end

    def save_records
      LogBook::SaveRecords.call
    end

    def current_author
      raise NotImplementedError unless respond_to?(LogBook.config.author_method, true)

      send(LogBook.config.author_method)
    end
  end
end
