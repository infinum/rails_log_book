module LogBook
  class Record < ActiveRecord::Base
    self.table_name = LogBook.config.records_table_name

    belongs_to :subject, polymorphic: true
    belongs_to :author, polymorphic: true
    belongs_to :parent, polymorphic: true
  end
end
