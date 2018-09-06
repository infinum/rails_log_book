module LogBook
  class SquashRecords
    def initialize(records)
      @records = records
    end

    def call
      records.group_by(&:parent).each do |parent, children|
        children_to_squash = children.select { |child| child.subject.try(:to_squash?) }
        next if children_to_squash.empty?

        if parent.present?
          parent_in_records = parent_in_records(parent)
          parent_in_records.record_changes.merge!(squashed_changes(children_to_squash, :record_changes))
          parent_in_records.meta.merge!(squashed_changes(children_to_squash, :meta))
          parent_in_records.created_at ||= children_to_squash.first.created_at
          parent_in_records.save

          children_to_squash.each(&:delete)
        else
          next if children_to_squash.one?

          records.reduce do |main_record, record|
            main_record.record_changes.merge!(record.record_changes)
            main_record.meta.merge!(record.meta)

            record.delete
            main_record
          end.save
        end
      end
    end

    private

    attr_reader :records

    def squashed_changes(children, key)
      children.each_with_object({}) do |record, object|
        object[record.subject_key] ||= {}
        object[record.subject_key][record.subject_id] = record.send(key)
      end
    end

    def parent_in_records(parent)
      records.find { |record| record.subject == parent } ||
        parent.new_record
    end
  end
end
