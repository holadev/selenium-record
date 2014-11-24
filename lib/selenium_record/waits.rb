#:nodoc:
module SeleniumRecord
  # Helpers to make easy waiting for something to happen
  module Waits
    DEFAULT_WAITING_TIME = 20

    def self.included(base)
      base.extend(ClassMethods)
    end

    # Wait selenium execution until no ajax request is pending in the browser
    # @param seconds [Integer] number of seconds to wait
    def wait_js_inactive(seconds = DEFAULT_WAITING_TIME)
      klass = self.class
      yield if block_given?
      klass.wait_for(seconds) do
        browser.execute_script(klass.js_inactive_script) == 0
      end
    end

    def wait_page_load
      self.class.wait_for do
        browser.execute_script('return document.readyState;') == 'complete'
      end
      load_dom
    end

    # Wait selenium execution until the element is displayed
    # @param locator [Hash] contains unique {key: value} where the key is the
    #   locator_type (:class, :class_name, :css, :id, :link_text, :link,
    #   :partial_link_text, :name, :tag_name, :xpath)
    def wait_displayed(locator, opts = {})
      klass = self.class
      klass.wait_for(klass.seconds_for(opts)) do
        begin
          evaluate_displayed(locator)
        rescue Selenium::WebDriver::Error::StaleElementReferenceError
          lookup unless parent_el
          false
        end
      end
    end

    # Waits until the 'model_view' corresponding to the model is completely
    # visible
    # @param model[PORO] plain old ruby object with a related 'model_view'
    def wait_fade_in(model)
      web_el = view_for(model).root_el
      self.class.wait_for { web_el.css_value('opacity').to_i == 1 }
    end

    # Waits until the 'model_view' corresponding to the model is completely
    # hidden
    # @param locator [Hash] contains unique {key: value} where the key is the
    #   locator_type (:class, :class_name, :css, :id, :link_text, :link,
    #   :partial_link_text, :name, :tag_name, :xpath)
    def wait_hidden(locator)
      self.class.wait_for do
        begin
          finder = root_el || browser
          element = finder.find_element(locator)
          !element.displayed?
        rescue Selenium::WebDriver::Error::StaleElementReferenceError
          true
        end
      end
    end

    private

    # @return element [Selenium::WebDriver::Element] if the element is visible.
    #   Otherwise returns nil.
    def evaluate_displayed(locator)
      finder = root_el || browser
      element = finder.find_element(locator)
      element if element.displayed?
    end

    # Utilities for waiting methods
    module ClassMethods
      # Wait selenium execution until a condition take place
      # @raise [Selenium::WebDriver::Error::TimeOutError] if the precondition we
      #   are waiting for doesn't take place after completing the wait period
      # @param seconds [Integer] number of seconds to wait
      # @yieldreturn [Boolean] marks whether the condition we are waiting for
      #   passes
      def wait_for(seconds = DEFAULT_WAITING_TIME)
        Selenium::WebDriver::Wait.new(timeout: seconds).until { yield }
      end

      # @return [String] the string containing javascript code to be evaluated
      #   to check if there are ajax calls pending
      def js_inactive_script
        {
          jquery: 'return $.active'
        }[Configuration.js_library]
      end

      def seconds_for(opts)
        seconds = opts[:seconds]
        return seconds if seconds
        20
      end
    end
  end
end
