ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :email

    t.timestamps
  end

  create_table :log_book_records, force: true do |t|
    t.belongs_to :author, polymorphic: true, index: true
    t.belongs_to :subject, polymorphic: true, index: true
    t.belongs_to :parent, polymorphic: true, index: true
    t.json :record_changes, default: {}
    t.json :meta, default: {}
    t.string :record_uuid

    t.datetime :created_at
  end
end
