module LogBook
  class SaveRecords
    def initialize
      @tree = LogBook::Store.tree
    end

    def self.call
      new.call
    end

    def call
      return unless LogBook.recording_enabled

      squash_tree(tree) if LogBook.record_squashing_enabled

      tree.records(only_roots: LogBook.record_squashing_enabled).each do |_key, record|
        create_record(record.value)
      end
    end

    private

    attr_reader :tree

    def squash_tree(tree)
      tree.depth.downto(1).each do |depth|
        nodes = tree.at_depth(depth)
        nodes.each do |_, node|
          next unless node.value.changes?
          parent = node.parent.value

          parent.record_changes = squashed_changes(node.value, parent.record_changes, :record_changes)
          parent.meta = squashed_changes(node.value, parent.meta, :meta)
        end
      end
    end

    def squashed_changes(record, object, key)
      object[record.subject_key] ||= {}
      object[record.subject_key][record.subject_id] = record.send(key)
      object
    end

    def create_record(record)
      return unless record.changes?

      attributes = record.to_h
      attributes.merge!(
        author: tree.author,
        action: tree.action,
        request_uuid: tree.request_uuid
      )
      LogBook::Record.create(attributes)
    end
  end
end
