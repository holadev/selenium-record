module SeleniumRecord
  # Selenium helpers for doing an action after a precondition takes place
  module Preconditions
    # Returns the first element matching the given arguments once this
    # element is displayed in the DOM
    # @param how [Symbol]  (:class, :class_name, :css, :id, :link_text, :link,
    #   :partial_link_text, :name, :tag_name, :xpath)
    # @param what [String]
    # @return element [Selenium::WebDriver::Element]
    def when_present(locator)
      element = wait_displayed(locator)
      yield if block_given?
      element
    end

    # @raise [Selenium::WebDriver::Error::TimeOutError] whether the element
    #   stays no clickable after time out period
    # @param locator [Hash] contains unique {key: value} where the key is the
    #   locator_type (:class, :class_name, :css, :id, :link_text, :link,
    #   :partial_link_text, :name, :tag_name, :xpath)
    # @return [Selenium::WebDriver::Element] once the element is clickable
    def when_clickable(locator)
      element = wait_clickable(locator)
      yield if block_given?
      element
    end

    def when_modal_present(title, &block)
      when_present(:xpath, modal_header_xpath(title), &block)
    end

    # @raise [Selenium::WebDriver::Error::TimeOutError] whether the element
    #   stays visible after time out period
    # @param locator [Hash] contains unique {key: value} where the key is the
    #   locator_type (:class, :class_name, :css, :id, :link_text, :link,
    #   :partial_link_text, :name, :tag_name, :xpath)
    # @return [Selenium::WebDriver::Element] once the element is hidden
    def when_hidden(locator)
      self.class.wait_for do
        begin
          element = root_el.find_element(locator)
          element unless element.displayed?
        rescue => error
          raise if error.is_a? Selenium::WebDriver::Error::TimeOutError
          true
        end
      end
    end
  end
end
