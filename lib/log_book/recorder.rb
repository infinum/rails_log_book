module LogBook
  module Recorder
    extend ActiveSupport::Concern

    module ClassMethods
      def has_log_book_records(options = {})
        class_attribute :recording_options, instance_writer: false

        self.recording_options = options

        has_many :records, -> { order(created_at: :asc) }, as: :subject, class_name: 'LogBook::Record'
        scope :with_records, -> { joins(:records) }

        on = Array.wrap(options[:on])
        after_create :store_changes if on.empty? || on.include?(:create)
        after_update :store_changes if on.empty? || on.include?(:update)
        after_destroy :store_changes if on.empty? || on.include?(:destroy)

        extend LogBook::Recorder::RecordingClassMethods
        include LogBook::Recorder::RecordingInstanceMethods
      end
    end

    module RecordingInstanceMethods
      def recording_changes
        @recording_changes ||= RecordingChanges.new(self)
      end

      def recording_options
        self.class.recording_options
      end

      def save_with_recording
        with_recording { save }
      end

      def with_recording(&block)
        self.class.with_recording(&block)
      end

      def recording_attributes
        attributes.except(*non_recording_columns)
      end

      def non_recording_columns
        self.class.non_recording_columns
      end

      def recording_key
        "#{self.class.table_name}_#{id}"
      end

      private

      def record_changes
        if recording_options[:only]
          recording_columns = self.class.recording_columns.map(&:name)
          saved_changes.slice(*recording_columns)
        else
          saved_changes.except(*non_recording_columns)
        end
      end

      def store_changes
        return unless LogBook.recording_enabled

        recording_changes.tap do |record|
          record.record_changes = record_changes
          record.meta = log_book_meta_info(record) if recording_options[:meta].present?
        end

        LogBook::Store.tree.add(recording_changes)
      end

      def log_book_meta_info(record)
        meta_options = recording_options[:meta]
        case meta_options
        when NilClass then nil
        when Symbol then send(meta_options, record)
        when Proc then meta_options.call(self, record)
        when TrueClass then log_book_meta(record)
        end
      end

      def log_book_meta(_record)
        raise NotImplementedError
      end
    end

    module RecordingClassMethods
      def recording_columns
        columns.select { |c| !non_recording_columns.include?(c.name) }
      end

      def non_recording_columns
        @non_recording_columns ||= begin
          options = recording_options
          if options[:only]
            except = column_names - Array.wrap(options[:only]).flatten.map(&:to_s)
          else
            except = default_ignored_attributes
            except |= Array(options[:except]).collect(&:to_s) if options[:except]
          end
          except
        end
      end

      def default_ignored_attributes
        [primary_key, inheritance_column, *Array.wrap(LogBook.config.ignored_attributes)]
      end
    end

    class RecordingChanges
      attr_reader :subject
      attr_reader :action
      attr_reader :author
      attr_reader :record_changes
      attr_reader :meta
      attr_reader :request_uuid
      attr_accessor :recording_key

      def initialize(recorder)
        @subject = recorder
        @recording_key = subject.recording_key
        @record_changes = {}
        @meta = {}
      end

      def record_changes=(value)
        @record_changes.merge!(value)
      end

      def meta=(value)
        @meta.merge!(value)
      end

      def changes?
        meta.present? || record_changes.present?
      end

      def subject_key
        subject.class.table_name
      end

      def subject_id
        subject.id
      end

      def parent
        self.class.new(subject.send(subject.recording_options[:parent])) if subject.recording_options[:parent]
      end

      def children
        self.class.new(subject.send(subject.recording_options[:parent_of])) if subject.recording_options[:parent_of]
      end

      def to_h
        {
          subject: subject,
          record_changes: record_changes,
          meta: meta
        }
      end
    end
  end
end
