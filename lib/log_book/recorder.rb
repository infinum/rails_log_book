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
        @recording_changes ||= { record_changes: {}, meta: {} }
      end

      def recording_parent
        return unless @recording_parent || recording_options[:parent]

        @recording_parent ||= send(recording_options[:parent])
      end

      def recording_parent=(val)
        @recording_parent = val
      end

      def recording_options
        self.class.recording_options
      end

      def to_squash?
        recording_options[:squash]
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
        return if record_changes.blank?

        update_recording_changes
        LogBook::Store.records.add(self)
      end

      def update_recording_changes
        recording_changes.tap do |record|
          record[:subject] ||= self
          record[:author] ||= LogBook::Store.author
          record[:action] ||= LogBook::Store.action
          record[:request_uuid] ||= LogBook::Store.request_uuid
          record[:parent] ||= recording_parent if recording_parent
          record[:record_changes].merge!(record_changes)
          record[:meta].merge!(log_book_meta_info(record)) if recording_options[:meta].present?
        end
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
  end
end
