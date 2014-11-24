module SeleniumRecord
  # Helpers for executing actions in custom scope
  module Scopes
    # Class for giving custom scope to selenium objects
    class LocatorScope < SimpleDelegator
      include Actions
      attr_accessor :scoped_locator

      def root_el
        @root_el ||= __rootel__.find_element(scoped_locator)
      end

      def find(locator)
        root_el.find_element(locator)
      end

      def find_elements(locator)
        root_el.find_elements(locator)
      end

      def run(&block)
        instance_eval(&block)
      end

      def class
        __getobj__.class
      end
    end

    # Executes the block passed as parameter in the scope associated to the
    # locator referenced by the scope name
    # @param name [Symbol] The name of the scope. Adding the suffix '_locator'
    #   it should match a locator name
    def scope(scope_name, &block)
      scope_obj = LocatorScope.new(self)
      scope_obj.scoped_locator = send "#{scope_name}_locator"
      scope_obj.run(&block)
    end
  end
end
