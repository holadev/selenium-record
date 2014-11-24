module SeleniumRecord
  # Defines configuration options
  class Configuration
    @js_library = :jquery
    @choose_option_max_retries = 10

    class << self
      attr_accessor :js_library, :choose_option_max_retries
    end
  end
end
