module LogBook
  class Store < ActiveSupport::CurrentAttributes
    # attribute :author
    # attribute :action
    # attribute :controller
    # attribute :request_uuid
    attribute :recording_enabled
    attribute :record_squashing

    attribute :tree

    def tree
      return super if super
      self.tree = LogBook::Tree.new
    end
  end
end
