require_relative 'base'

module SeleniumRecord
  # Base model to be extended by all Selenium page objects
  class NavigationItem < Base
    lookup_strategy :root

    def before_load_dom
      before_navigate if respond_to? :before_navigate
      navigate unless current?
    end

    def click_link(*args)
      super
      self
    end

    def reload
      find(link_active_locator).click
      wait_page_load
      self
    rescue => error
      if error.is_a? Selenium::WebDriver::Error::StaleElementReferenceError
        load_dom
        retry
      else
        raise
      end
    end

    # Class method to create the 'before_navigate' hook defining the title
    # of the page
    # @param key [String] key to lookup text translation for menu title of
    #   the page
    def self.navigate_to(key)
      define_method :before_navigate do
        @title = trans key
      end
    end

    private

    # Checks whether the current page corresponds to the instance page and
    # in case of mismatch clicks on the navigation menu for loading the
    # instance page
    def navigate
      when_present(link_inactive_locator).click
      wait_displayed(link_active_locator)
    end

    # @param [String] Returns the xpath to be used to identify if the current
    #   browser page matches this object
    # @raise [SubclassResponsabilityError] if subclasses don't implement this
    #   method
    def link_inactive_locator
      fail SUBCLASS_RESPONSABILITY
    end

    def link_active_locator
      fail SUBCLASS_RESPONSABILITY
    end

    # @return [Boolean] Marks whether the current browser page matches the new
    #   new instantiated page object
    def current?
      browser.find_element(link_active_locator)
    rescue Selenium::WebDriver::Error::NoSuchElementError
      false
    end
  end
end
