module SeleniumRecord
  # Helpers for getting html related info to selenium objects
  module Html
    # @return [String] the html content for the root element
    def to_html
      return root_el.attribute('innerHTML') if exist?
      nil
    end

    # @return [String] the tag name for the DOM element at the root of the
    #   object. Used to define xpath locators.
    # @see preceding_sibling_locator
    def tag_name
      @tag_name ||= root_el.attribute('tagName')
    end
  end
end
