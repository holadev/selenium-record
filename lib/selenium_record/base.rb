require_relative 'core'
require_relative 'lookup'
require_relative 'actions'
require_relative 'action_builder'
require_relative 'scopes'
require_relative 'waits'
require_relative 'preconditions'
require_relative 'axis'
require_relative 'html'
require_relative 'theme'
require_relative 'translations'

# SeleniumRecord provides a framework based on the Selenium Page Object pattern
#
# ### More references:
# - [Selenium Wiki Page](https://code.google.com/p/selenium/wiki/PageObjects)
# - "Selenium 2 Testing Tools" by David Burns
module SeleniumRecord
  # @abstract Subclass and override {#run} to implement
  #   a custom Selenium object
  class Base
    include Core
    include Lookup
    include Actions
    include ActionBuilder
    include Scopes
    include Waits
    include Preconditions
    include Axis
    include Html
    include Theme
    include Translations
    attr_reader :browser, :parent_el, :root_el, :object
    alias_method :__rootel__, :root_el

    # @params browser [Selenium::WebDriver::Driver]
    # @param [Hash] opts the options to create a new record
    # @option opts [Selenium::WebDriver::Element] :parent_el The parent element
    # @option opts [Selenium::WebDriver::Element] :root_el The root element
    # @option opts [PORO] :object Plain Old Ruby Object contains main info
    #   related to the record
    def initialize(browser, opts = {})
      @browser = browser
      @parent_el = opts[:parent_el]
      @root_el = opts[:root_el]
      @object = opts[:object]
    end

    # Creates a view in the scope of current instance based on object model
    #   passed as parameter
    # @param object [ActiveRecord::Base] the object related to the new view
    # @param [Hash] opts the options for the new view created
    # @option opts [Module] :namespace The namespace in which the new view
    #   should be created
    # @option opts [String] :suffix The suffix to be appended to the new view
    #   class name
    def create_record(object, opts = {})
      subject = opts[:subject] || object.class.name
      klass = self.class.extract_klass(subject, opts)
      klass.new(@browser, parent_el: root_el, object: object)
    end

    # Creates a view in the scope of current instance based on the action name
    # @param action [Symbol]
    # @param [Hash] opts the options for the new view created
    # @option opts [Module] :namespace The namespace in which the new view
    #   should be created
    # @option opts [String] :suffix The suffix to be appended to the new view
    #   class name
    def create_record_for_action(action, opts = {})
      klass = self.class.extract_klass(action.to_s.camelize, opts)
      klass.new(@browser, parent_el: root_el)
    end

    # @return [Boolean] returns whether the view is attached to the dom
    def exist?
      load_dom if respond_to? :lookup_sequence
      root_el != nil
    end

    # @param [Hash] opts the options for the new view created
    # @option opts [Module] :namespace The namespace in which the new view
    #   should be created
    # @option opts [String] :suffix The suffix to be appended to the new view
    #   class name
    # @return [SeleniumRecord::Base]
    def self.extract_klass(subject, opts)
      namespace = opts[:namespace] || Object
      suffix = opts[:suffix] || ''
      namespace.const_get("#{subject}#{suffix}")
    end
  end
end
