module LogBook
  class Record < ActiveRecord::Base
    self.table_name = LogBook.config.records_table_name

    belongs_to :subject, polymorphic: true
    belongs_to :author, polymorphic: true
    belongs_to :parent, polymorphic: true
    serialize  :record_changes, LogBook.config.records_serialize_to
    serialize  :meta, LogBook.config.records_serialize_to

    before_create :set_record_author, :set_request_uuid

    def self.collection_cache_key(collection = all, timestamp_column = :created_at)
      super(collection, timestamp_column)
    end

    def subject_key
      subject.class.table_name
    end

    private

    def set_record_author
      self.author = LogBook.store[:author]
    end

    def set_request_uuid
      self.request_uuid = LogBook.store[:request_uuid]
    end
  end
end
