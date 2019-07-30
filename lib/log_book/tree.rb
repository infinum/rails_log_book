module LogBook
  class Tree
    attr_accessor :author, :action, :request_uuid, :nodes, :depth

    def initialize(author: nil, action: nil, request_uuid: nil)
      @nodes = {}
      @depth = 0
      @author = author
      @action = action
      @request_uuid = request_uuid
    end

    def add(record)
      node = nodes[record.recording_key]
      node = node ? node.merge(record) : nodes[record.recording_key] = Node.new(record)
      add_parent(node, record.parent)
      add_children(node, record.children)
    end

    def add_parent(node, parent)
      return unless parent

      parent_node = nodes[parent.recording_key] ||= Node.new(parent)
      node.parent = parent_node
      parent_node.children << node
      update_depth(parent_node, parent_node.depth)
    end

    def add_children(node, children)
      return unless children

      Array.wrap(children).each do |child|
        add_child(node, child)
      end
    end

    def add_child(node, child)
      return unless child

      child_node = nodes[child.recording_key] ||= Node.new(child)
      child_node.parent = node
      node.children << child_node
      update_depth(node, node.depth)
    end

    def update_depth(node, depth)
      node.depth = depth
      @depth = [@depth, depth].max
      node.children.each do |child|
        update_depth(child, depth + 1)
      end
    end

    def records(only_roots: false)
      only_roots ? at_depth(0) : nodes
    end

    def at_depth(depth)
      nodes.select { |_, node| node.depth == depth}
    end

    class Node
      attr_reader :value
      attr_accessor :parent
      attr_accessor :children
      attr_accessor :depth

      def initialize(value)
        @value = value
        @depth = 0
        @children = []
      end

      def merge(new_value)
        value.record_changes = new_value.record_changes
        self
      end
    end
  end
end
