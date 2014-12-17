module SeleniumRecord
  # Contains simple actions to play from selenium objects
  module Actions
    def textarea_content(locator, content)
      find(locator).clear  # gain focus on textarea
      find(locator).send_keys content
    end

    # Clicks accept button on popup
    def accept_popup
      popup = browser.switch_to.alert
      popup.accept
    end

    # Chooses an option from select enhanced by javascript
    # @param id [String] id of the select
    # @param text [String] the option text
    def choose_option(id, text)
      click_wait xpath: select_xpath(id)
      click_wait xpath: select_option_xpath(id, text)
    end

    # Chooses a menu from dropdown enhanced by javascript
    # @param dropdown [String] text of dropdown
    # @param menu [String] text of menu
    def choose_menu(dropdown, menu)
      click_wait xpath: dropdown_xpath(trans dropdown)
      click_wait xpath: dropdown_menu_xpath(trans menu)
    end

    # Clear input of type 'text'
    def clear(locator)
      el = find(locator)
      el.send_keys('')
      el.clear
    end

    def click_on(locator)
      find(locator).click
    end

    # Clicks on element and wait until all jquery events are dispatched
    # @param how [Symbol]  (:class, :class_name, :css, :id, :link_text, :link,
    #   :partial_link_text, :name, :tag_name, :xpath)
    # @param what [String]
    def click_wait(locator)
      when_present(locator).click
      wait_js_inactive
    end

    def click(locator)
      find(locator).click
    end

    def fill(locator, text)
      return unless text
      clear(locator)
      find(locator).send_keys(text || '')
    end

    # @param locator [Hash|Selenium::WebDriver::Element]
    def focus(locator)
      element = (locator.is_a?(Hash) && find(locator)) || locator
      browser.action.move_to(element).perform
    end

    def submit
      click(xpath: ".//button[@type='submit']")
      wait_page_load
      load_dom
    end

    # @param text [String] text of the link to be clicked
    def click_link(text)
      finder = root_el || browser
      finder.find_element(link_text: text).click
    end

    # Drops the model view on the bottom to the top of the model type view list
    # @param model_type [Symbol] the type of the views to be affected
    def pop_last(model_type)
      elements = send("#{model_type}_elements")
      browser.action
        .drag_and_drop(elements.last, elements.first).perform
    end

    # @param id [Symbol] id of select element
    # @param text [String] text of the option to be selected
    def select_from_chosen(id, text)
      browser.execute_script <<-script
        var optValue = $("##{id} option:contains('#{text}')").val();
        var value = [optValue];
        if ($('##{id}').val()) {
          $.merge(value, $('##{id}').val());
        }
        $('##{id}').val(value).trigger('chosen:updated');
      script
    end

    # Remove once all helper references belongs to selenium objects
    module_function :choose_option
  end
end
