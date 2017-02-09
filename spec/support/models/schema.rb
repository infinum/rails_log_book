ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :email
    t.string :name
    t.string :address
    t.belongs_to :company

    t.timestamps
  end

  create_table :companies, force: true do |t|
    t.string :name

    t.timestamps
  end

  create_table :company_infos, force: true do |t|
    t.string :address
    t.belongs_to :company

    t.timestamps
  end

  create_table LogBook.config.records_table_name, force: true do |t|
    t.belongs_to :author, polymorphic: true, index: true
    t.belongs_to :subject, polymorphic: true, index: true
    t.belongs_to :parent, polymorphic: true, index: true
    t.json :record_changes, default: {}
    t.json :meta, default: {}
    t.string :request_uuid
    t.string :action

    t.datetime :created_at
  end
end
