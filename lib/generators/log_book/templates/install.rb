class <%= migration_class_name %> < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :records do |t|
      t.belongs_to :author, polymorphic: true, index: true
      t.belongs_to :subject, polymorphic: true, index: true
      t.belongs_to :parent, polymorphic: true, index: true
      t.jsonb :record_changes, default: {}
      t.jsonb :meta, default: {}
      t.string :request_uuid, index: true
      t.string :action

      t.datetime :created_at
    end
  end
end
