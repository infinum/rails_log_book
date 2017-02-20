module LogBook
  class Record < ActiveRecord::Base
    self.table_name = LogBook.config.records_table_name

    belongs_to :subject, polymorphic: true
    belongs_to :author, polymorphic: true
    belongs_to :parent, polymorphic: true

    before_create :set_request_uuid

    def self.collection_cache_key(collection = all, timestamp_column = :created_at)
      super(collection, timestamp_column)
    end

    def subject_key
      subject.class.table_name
    end

    def changes_to_record?
      !(record_changes == {} && skip_if_empty_actions.include?(action))
    end

    private

    def set_request_uuid
      self.request_uuid ||= LogBook.store[:request_uuid] || SecureRandom.uuid
    end

    def skip_if_empty_actions
      (subject.recording_options[:skip_if_empty_actions] || LogBook.config.skip_if_empty_actions).map(&:to_s)
    end
  end
end
