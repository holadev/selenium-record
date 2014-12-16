module SeleniumRecord
  # Defines configuration options
  module Configuration
    @js_library = :jquery
    @choose_option_max_retries = 10

    class << self
      attr_accessor :js_library, :choose_option_max_retries, :objects_module
    end

    # param object_type [Symbol] The object type
    # @return [Module] The module containing classes of object type
    def so_module(object_type = nil)
      base_module = SeleniumRecord::Configuration.objects_module
      return base_module unless object_type
      klass = object_type.to_s.classify.pluralize
      base_module.const_get(klass)
    end
  end
end
