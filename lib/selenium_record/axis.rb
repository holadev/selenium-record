module SeleniumRecord
  # Helper methods for comparing the relative position in DOM among selenium
  # objects
  module Axis
    # @param view [SeleniumRecord::Base]
    # @return [Boolean] Marks whether the current view is located in DOM
    #   after the view passed as parameter
    def after?(other_view)
      preceding_sibling_elements.member? other_view.root_el
    end

    # @param view [SeleniumRecord::Base]
    # @return [Boolean] Marks whether the current view is located in DOM
    #   before the view passed as parameter
    def before?(other_view)
      following_sibling_elements.member? other_view.root_el
    end

    # @param models [Array<PORO>] list of models associated to views
    # @return [Boolean] Marks whether the model views are ordered in the dom
    def ordered?(*models)
      result = []
      models.reduce(nil) do |prev, current|
        result << (view_for(prev).before? view_for(current)) if prev
        current
      end
      result.any?
    end

    # Returns all elements belonging to preceding sibling xpath axe
    # @return [Array<Selenium::WebDriver::Element>]
    def preceding_sibling_elements
      find_elements(preceding_sibling_locator)
    end

    # Returns all elements belonging to following sibling xpath axe
    # @return [Array<Selenium::WebDriver::Element>]
    def following_sibling_elements
      find_elements(following_sibling_locator)
    end

    private

    # @return [String] locator for finding preceding sibling dom elements
    def preceding_sibling_locator
      { xpath: "./preceding-sibling::#{tag_name}" }
    end

    # @return [String] locator for finding following sibling dom elements
    def following_sibling_locator
      { xpath: "./following-sibling::#{tag_name}" }
    end
  end
end
