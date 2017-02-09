module LogBook
  module ControllerRecord
    extend ActiveSupport::Concern

    included do
      before_action :enable_recording
      around_action :record_squashing
    end

    def enable_recording
      LogBook.store[:controller] = self
      LogBook.store[:author] = current_author
      LogBook.store[:request_uuid] = try(:request).try(:uuid) || SecureRandom.hex
      LogBook.enable_recording
    end

    def record_squashing
      LogBook.with_record_squashing do
        yield
      end
    end

    def current_author
      raise NotImplementedError unless respond_to?(LogBook.config.author_method)
      send(LogBook.config.author_method)
    end
  end
end
