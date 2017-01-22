module LogBook
  class Record < ActiveRecord::Base
    self.table_name = 'log_book_records'

    belongs_to :subject, polymorphic: true
    belongs_to :author, polymorphic: true
    belongs_to :parent, polymorphic: true
    serialize  :record_changes, JSON
    serialize  :meta, JSON

    before_create :set_record_author, :set_record_uuid

    # self.audited_class_names = Set.new

    # All audits made during the block called will be recorded as made
    # by +user+. This method is hopefully threadsafe, making it ideal
    # for background operations that require audit information.
    # def self.as_author(author)
    #   log_book_store[:record_author] = author
    #   yield
    # ensure
    #   log_book_store[:record_author] = nil
    # end

    def self.collection_cache_key(collection = all, timestamp_column = :created_at)
      super(collection, timestamp_column)
    end

    private

    def set_record_author
      self.author = LogBook.log_book_store[:record_author] if LogBook.log_book_store[:record_author]
      nil # prevent stopping callback chains
    end

    def set_record_uuid
      self.record_uuid ||= SecureRandom.uuid
    end
  end
end
