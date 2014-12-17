module SeleniumRecord
  # Core helpers to get easier access to selenium api
  module Core
    SUBCLASS_RESPONSABILITY = 'SubclassResponsibilityError'

    def load_dom!(attrs = {})
      @load_attributes = attrs
      before_load_dom if respond_to? :before_load_dom
      before_lookup if respond_to? :before_lookup
      lookup
      after_load_dom if respond_to? :after_load_dom
      self
    end

    def load_dom(attrs = {})
      load_dom! attrs
    rescue
      false
    end

    # @param [Hash] opts the options to find element
    # @param opts [String] :global_scope Marks whether the global scope is used
    #   whenever a root element is not present
    # @return [Selenium::WebDriver::Element]
    def find(locator, opts = {})
      cover do
        finder = root_el
        finder = browser if opts[:global_scope] && !finder
        element = finder.find_element(locator)
        element.extend(Axiable)
        element
      end
    end

    def find!(locator)
      find(locator, global_scope: true)
    end

    def find_elements(locator)
      cover { root_el.find_elements(locator) }
    end

    def first_last(list)
      blk = ->(first, *_, last) { [first, last] }
      blk.call(*list)
    end

    protected

    # Runs block code free of:
    # `Selenium::WebDriver::Error::StaleElementReferenceError`
    # Case the exception is raised it is reloaded the dom of the object
    #
    # @param block [Block] The block of code to be executed
    def cover(&block)
      block.call
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      load_dom
      retry
    end
  end
end
