module LogBook
  class SquashRecords
    def initialize(records)
      @records = records
    end

    def call
      records.group_by(&:parent).each do |parent, children|
        next if parent.nil?

        parent_in_records = parent_in_records(parent, children.first)
        parent_in_records.record_changes.merge!(squashed_changes(children, :record_changes))
        parent_in_records.meta.merge!(squashed_changes(children, :meta))
        parent_in_records.save

        children.each(&:delete)
      end
    end

    private

    attr_reader :records

    def squashed_changes(children, key)
      children.each_with_object({}) do |record, object|
        object[record.subject_key] ||= {}
        object[record.subject_key][record.subject_id] = record.send(key)[record.subject_key]
      end
    end

    def parent_in_records(parent, child)
      records.find { |record| record.subject == parent } ||
        Record.new(
          subject: parent, record_changes: {}, meta: {},
          action: child.action,
          request_uuid: child.request_uuid,
          author: child.author
        )
    end
  end
end
