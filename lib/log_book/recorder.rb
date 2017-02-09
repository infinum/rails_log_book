module LogBook
  module Recorder
    extend ActiveSupport::Concern

    module ClassMethods
      def has_log_book_records(options = {})
        class_attribute :recording_options, instance_writer: false

        self.recording_options = options

        has_many :records, -> { order(created_at: :asc) }, as: :subject

        on = Array.wrap(options[:on])
        after_create :create_record if on.empty? || on.include?(:create)
        after_update :update_record if on.empty? || on.include?(:update)
        after_destroy :destroy_record if on.empty? || on.include?(:destroy)

        extend LogBook::Recorder::RecordingClassMethods
        include LogBook::Recorder::RecordingInstanceMethods
      end
    end

    module RecordingInstanceMethods
      def to_squash?
        recording_options[:squash]
      end

      def save_with_recording
        with_recording { save }
      end

      def with_recording(&block)
        self.class.with_recording(&block)
      end

      def changes_to_record
        attrs = {
          action: LogBook.store[:action],
          record_changes: record_changes,
          subject: self,
          author: LogBook.store[:author],
          meta: {}
        }
        attrs[:meta] = log_book_meta_info if recording_options[:meta].present?
        attrs[:parent] = send(recording_options[:parent]) if recording_options[:parent].present?
        attrs
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
          changes.slice(*recording_columns)
        else
          changes.except(*non_recording_columns)
        end
      end

      def create_record
        write_record(:create)
      end

      def update_record
        write_record(:update)
      end

      def destroy_record
        write_record(:destroy)
      end

      def write_record(action)
        return unless LogBook.recording_enabled
        LogBook.store[:action] ||= action
        LogBook::Record.create(changes_to_record)
      end

      def log_book_meta_info
        case recording_options[:meta]
        when NilClass then nil
        when Symbol then send(recording_options[:meta])
        when Proc then recording_options[:meta].call(self)
        when TrueClass then log_book_meta
        end
      end

      def log_book_meta
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
