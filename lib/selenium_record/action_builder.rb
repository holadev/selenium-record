module SeleniumRecord
  # Helpers for building complex actions
  module ActionBuilder
    # Class for storing action info
    class Action
      attr_reader :method, :args
      def initialize(method, args = [])
        @method = method
        @args = args
      end
    end

    # Class for building complex actions
    class Builder
      attr_accessor :actions

      def initialize(&block)
        @actions = []
        @blk = block
      end

      def perform
        @actions.each { |action| @blk.call(action.method, action.args) }
        @actions.freeze
      end

      def method_missing(method, *args)
        @actions << Action.new(method, *args)
        self
      end
    end

    # @param block [Block] the block over all actions will be performed. It
    #   should contain two params: |method, args|
    # @return [SeleniumRecord::Builder::ActionBuilder] a new action builder
    #   instance
    def action_builder(&block)
      Builder.new(&block)
    end
  end
end
