module LogBook
  module ControllerRecord
    extend ActiveSupport::Concern

    included do
      before_action :enable_recording
    end

    def enable_recording
      LogBook.store[:action] = action_name
      LogBook.store[:controller] = self
      LogBook.store[:author] = send(self.class.author_method)
      LogBook.store[:record_uuid] = try(:request).try(:uuid) || SecureRandom.uuid
      LogBook.enable_recording
    end

    module ClassMethods
      def override_author_method(val)
        @author_method = val
      end

      def author_method
        @author_method || LogBook.config.author_method
      end
    end

    # def around(controller)
    #   self.controller = controller
    #   yield
    # ensure
    #   self.controller = nil
    # end
    #
    # def before_create(audit)
    #   audit.user ||= current_user
    #   audit.remote_address = controller.try(:request).try(:remote_ip)
    #   audit.request_uuid = request_uuid if request_uuid
    # end
    #
    #
    # def request_uuid
    #   controller.try(:request).try(:uuid)
    # end
    #
    # def add_observer!(klass)
    #   super
    #   define_callback(klass)
    # end
    #
    # def define_callback(klass)
    #   observer = self
    #   callback_meth = :_notify_audited_sweeper
    #   klass.send(:define_method, callback_meth) do
    #     observer.update(:before_create, self)
    #   end
    #   klass.send(:before_create, callback_meth)
    # end
    #
    # def controller
    #   ::Audited.store[:current_controller]
    # end
    #
    # def controller=(value)
    #   ::Audited.store[:current_controller] = value
    # end
  end
end
