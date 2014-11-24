module SeleniumRecord
  # Responsible methods for looking up the root element for each selenium object
  module Lookup
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Searchs for root element of current object based on other element
    # @return [Webdriver::Element]
    def lookup
      @root_el = parent_el || browser
      lookup_sequence.each { |locator| @root_el = lookup_step(locator) }
    rescue
      @root_el = nil
      raise
    end

    # Given the current root element for the view, applies a scoped search for
    # the web element identified by the locator passed as parameter
    #
    # @raise [LookupMultipleElementsError] if it is found multiple web elements
    #   in the scope of the current root element for the locator passed
    # @raise [LookupUndefinedElementError] if it isn't found any web elements
    #   in the scope of the current root element for the locator passed
    #
    # @param locator [Hash] contains unique {key: value} where the key is the
    #   locator_type (:class, :class_name, :css, :id, :link_text, :link,
    #   :partial_link_text, :name, :tag_name, :xpath)
    # @return element [Selenium::WebDriver::Element]
    def lookup_step(locator)
      lookup_elements = find_elements(locator)
      size = lookup_elements.size
      fail 'LookupMultipleElementsError' if size > 1
      fail 'LookupUndefinedElementError' if size == 0
      lookup_elements.first
    end

    # Clasess extending SeleniumRecord::Base should overwrite this method or
    # call to class method `lookup_strategy` defined in `SeleniumRecord::Lookup`
    # in order to search for Selenium::WebDriver::Element used as scope for
    # finding elements inside the instance object
    def lookup_sequence
      fail 'LookupUndefinedSequenceError'
    end

    # Contains class method helpers and definition of classes for lookup
    # strategy
    module ClassMethods
      # @param strategy_sym [Symbol] lookup strategy corresponding with the
      #   name of a lookup strategy locator
      def lookup_strategy(strategy_sym, opts = {})
        locator_klass = "Lookup#{strategy_sym.to_s.camelize}Strategy"
        Module.nesting.shift.const_get(locator_klass).new(self, opts).run
      end

      # Base class for all lookup strategies
      class LookupStrategy
        attr_reader :lookup_attributes

        # @param klass [SeleniumObject::Base] class on top over it is defined
        #   the lookup strategy
        # @param attrs [Hash] attributes used while it is the defined the
        #   lookup sequence
        def initialize(klass, attrs = {})
          @klass = klass
          @attributes_blk = -> { attrs }
        end

        # Defines for the class the instance methods required for the lookup
        # sequence. Inside the block you have access to the "lookup_attributes"
        # specified in the constructor call
        # @param [Block] block defining the lookup sequence
        def lookup_sequence(&block)
          attributes_blk = @attributes_blk
          before_lookup_blk = before_run if respond_to? :before_run
          @klass.instance_eval do
            define_method :lookup_attributes, attributes_blk
            define_method :lookup_sequence, &block
            define_method :before_lookup, before_lookup_blk if before_lookup_blk
          end
        end
      end

      # Defines a lookup sequence relative to the title xpath
      class LookupRelativeTitleStrategy < LookupStrategy
        def run
          lookup_sequence do
            [title_locator, lookup_attributes[:locator]]
          end
        end
      end

      # Defines a lookup sequence relative to the xpath of an element present in
      # the selenium object
      class LookupRelativePathStrategy < LookupStrategy
        def run
          lookup_sequence do
            [send("#{lookup_attributes[:to]}_locator"),
             lookup_attributes[:locator]]
          end
        end
      end

      # Defines a lookup sequence matching an element path
      class LookupMatchingStrategy < LookupStrategy
        def run
          lookup_sequence { [lookup_attrs[:locator]] }
        end
      end

      # Defines a lookup sequence matching the whole document body
      class LookupRootStrategy < LookupStrategy
        def run
          lookup_sequence { [{ xpath: '//body' }] }
        end

        def before_run
          -> { @parent_el = nil }
        end
      end
    end
  end
end
