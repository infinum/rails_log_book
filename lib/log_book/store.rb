module LogBook
  class Store < ActiveSupport::CurrentAttributes
    # attribute :author
    # attribute :action
    # attribute :controller
    # attribute :request_uuid
    attribute :recording_enabled
    attribute :record_squashing

    attribute :tree
  end
end
