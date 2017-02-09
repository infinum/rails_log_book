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
    attr_accessor :ignored_attributes
    attr_accessor :recording_enabled
    attr_accessor :author_method
    attr_accessor :record_squashing

    def initialize
      @records_table_name = 'records'
      @ignored_attributes = [:updated_at, :created_at]
      @author_method = :current_user
      @record_squashing = false
      @recording_enabled = false
    end
  end
end
