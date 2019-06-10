module LogBook
  class SaveRecords
    def initialize
      @records = LogBook::Store.records
    end

    def self.call
      new.call
    end

    def call
      return unless LogBook.recording_enabled

      @records = squash_records if LogBook.record_squashing_enabled

      records.each do |record|
        create_record(record)
      end
    end

    private

    attr_reader :records

    def squash_records
      records.each_with_object(Set.new) do |record, new_records|
        if !record.to_squash? || record.recording_parent.blank?
          new_records.add(record)
        else

          parent = records.find { |r| r == record.recording_parent }
          parent = parent_from_record(record) if parent.nil?

          parent.recording_changes.tap do |changes|
            changes[:record_changes] = squashed_changes(record, changes[:record_changes], :record_changes)
            changes[:meta].merge(squashed_changes(record, changes[:meta], :meta))
          end
          new_records.add(parent)
        end
      end
    end

    def squashed_changes(record, object, key)
      object[record.class.table_name] ||= {}
      object[record.class.table_name][record.id] = record.recording_changes[key]
      object
    end

    def parent_from_record(record)
      parent = record.recording_parent
      parent.recording_changes.tap do |parent_record|
        parent_record[:subject] ||= parent
        parent_record[:author] ||= record.recording_changes[:author]
        parent_record[:action] ||= record.recording_changes[:action]
      end
      parent
    end


    def create_record(record)
      LogBook::Record.create(record.recording_changes)
    end
  end
end
