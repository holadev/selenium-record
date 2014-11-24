module SeleniumRecord
  # Helpers specific for the bootstrap theme
  module Theme
    def modal_header_xpath(key)
      "//div[@class='modal-header']/h3[text()='#{trans(key)}')]"
    end

    def find_headline(text)
      xpath = "//div[contains(@class,'headline')]//div[contains(.,'#{text}')]"
      find(:xpath, xpath)
    end

    # Returns xpath for select decorated with chosen.jquery.js
    # @param [String] id of the select
    def select_xpath(id)
      ".//div[@id='#{id}_chosen']/a"
    end

    def select_option_xpath(id, text)
      ".//div[@id='#{id}_chosen']//li[text()='#{text}']"
    end

    # Returns xpath for the dropdown button that matches the text
    # @param key [String] text of dropdown button
    def dropdown_xpath(text)
      ".//button[contains(.,'#{text}')]"
    end

    # Returns xpath for the select option that matches the text
    # @param key [String] text of select option
    def dropdown_menu_xpath(text)
      ".//ul[@class='dropdown-menu']/li[contains(.,'#{text}')]/a"
    end

    def section_xpath(text)
      ".//section//div[@class='panel-header']
       /h3[@class='suspended area-name']/strong/a[contains(.,'#{text}')]"
    end
  end
end
