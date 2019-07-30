module LogBook
  extend Dry::Configurable

  setting :records_table_name,    'records'
  setting :ignored_attributes,    [:updated_at, :created_at]
  setting :always_record,         false
  setting :author_method,         :current_user
  setting :record_squashing,      false
  setting :skip_if_empty_actions, [:update]
end
