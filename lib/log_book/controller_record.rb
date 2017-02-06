module LogBook
  module ControllerRecord
    extend ActiveSupport::Concern

    included do
      before_action :enable_recording
      around_action :record_squashing
    end

    def enable_recording
      LogBook.store[:action] = action_name
      LogBook.store[:controller] = self
      LogBook.store[:author] = send(self.class.author_method)
      LogBook.store[:request_uuid] = try(:request).try(:uuid) || SecureRandom.uuid
      LogBook.enable_recording
    end

    def record_squashing
      LogBook.with_record_squashing do
        yield
      end
    end

    module ClassMethods
      def override_author_method(val)
        @author_method = val
      end

      def author_method
        @author_method || LogBook.config.author_method
      end
    end
  end
end
