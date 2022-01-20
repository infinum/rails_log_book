module LogBook
  extend Dry::Configurable

  setting :records_table_name,    default: 'records'
  setting :ignored_attributes,    default: [:updated_at, :created_at]
  setting :always_record,         default: false
  setting :author_method,         default: :current_user
  setting :record_squashing,      default: false
  setting :skip_if_empty_actions, default: [:update]
end
