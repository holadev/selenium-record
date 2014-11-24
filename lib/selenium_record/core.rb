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

    def click_on(locator)
      find(locator).click
    end

    def find(locator)
      root_el.find_element(locator)
    end

    def find_elements(locator)
      root_el.find_elements(locator)
    end

    def first_last(list)
      blk = ->(first, *_, last) { [first, last] }
      blk.call(*list)
    end
  end
end
