class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :records do |t|
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
end
