module SeleniumRecord
  # Xpath axes helper methods for extending Selenium::WebDriver::Element
  module Axiable
    # @param element [Selenium::WebDriver::Element]
    # @return [Selenium::WebDriver::Element] The preceding-sibling axis element
    def preceding_sibling(tag_name = '*')
      find_element xpath: "./preceding-sibling::#{tag_name}"
    end

    def parent(tag_name = '*')
      find_element xpath: "./parent::#{tag_name}"
    end
  end
end
