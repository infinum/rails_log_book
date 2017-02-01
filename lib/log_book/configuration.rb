module LogBook
  def self.configure
    @configuration ||= Configuration.new
    yield(@configuration)
  end

  def self.config
    @configuration ||= Configuration.new
  end

  class Configuration
    attr_accessor :records_table_name
    attr_accessor :records_serialize_to
    attr_accessor :ignored_attributes
    attr_accessor :recording_enabled
    attr_accessor :record_class_name
    attr_accessor :ignored_attributes

    def initialize
      @records_table_name = 'records'
      @record_class_name = Record
      @records_serialize_to = JSON
      @ignored_attributes = []
      @ignored_attributes = [:updated_at, :created_at]
    end
  end
end