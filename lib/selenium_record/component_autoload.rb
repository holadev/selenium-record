module SeleniumRecord
  # Provides shortcuts for selenium object creation
  module ComponentAutoload
    # Error raised when it is not found the component
    class UnknownComponent < StandardError
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.instance_eval do
        attr_reader :components
      end
    end

    # @param modules [Array<String>]
    # @return [Module] the module containing the classes for the marker type
    #   group
    def self.extract_namespace(*modules)
      modules.compact.reduce(so_module) do |klass, sym|
        klass.const_get(sym)
      end
    end

    # @param suffixes [Array<String>]
    def self.extract_group(klass_name, opts = {})
      return unless opts[:nested_folder]
      suffixes = [*opts[:suffixes]]
      suffixes.map do |suffix|
        match_data = Regexp.new("^(.*)#{suffix}$").match(klass_name)
        match_data[1] if match_data
      end.compact.first
    end

    # @param component_type [Symbol]
    # @param item [Symbol]
    # @param klass [SeleniumRecord::Base]
    # @param suffixes [Array<String>]
    def self.extract_options(component_type, klass, opts = {})
      suffix = component_type.to_s.capitalize
      group = extract_group(klass.name.split('::').last, opts)
      namespace = extract_namespace(suffix.pluralize, group)
      { namespace: namespace, suffix: suffix, subject: opts[:subject] }
    end

    # @param component_type [Symbol] type of component
    # @param _ [String] the return type to show in autogenerated documentation
    # @param [Hash] opts the options of component loader
    # @param opts [Array<String>] suffixes The list of valid suffixes for
    #   parent classes of the instantiated component
    # @option opts [String] :nested_folder Marks whether to search the
    #   component inside a folder specific to parent component
    def self.component_loader(component_type, _, opts = {})
      mod = self
      define_method "#{component_type}_for" do |item|
        record_opts = mod.extract_options(component_type, self.class, {
          subject: item.to_s.camelize,
          suffixes: %w(View)
        }.merge(opts))
        create_record(object, record_opts).tap(&:load_dom)
      end
    end

    # @macro [attach] component
    #   @method $1_for($1_sym)
    #   @param $1_sym [Symbol]
    #   @return [$2]
    component_loader :panel, 'SeleniumRecord::Base', nested_folder: true,
                                                     suffixes: %w(Pill)
    component_loader :tab, 'SeleniumObjects::Tabs::ApplicationTab',
                     nested_folder: true
    component_loader :pill, 'SeleniumObjects::Pills::ApplicationPill',
                     nested_folder: true, suffixes: %w(Tab)
    component_loader :modal, 'SeleniumRecord::Base'

    # @param model [ActiveRecord::Base]
    # @return [SeleniumObject::View::ApplicationView]
    def view_for(model)
      create_record(model, namespace: so_module(:views), suffix: 'View')
        .tap(&:load_dom)
    end

    # Proxies all calls to component methods
    def method_missing(method, *args)
      [*@components].each do |comp|
        return comp.send(method, *args) if comp.respond_to?(method)
      end
    rescue UnknownComponent
      super
    end

    # Class method helpers for autoloading components
    module ClassMethods
      def component_method_regex
        /(?<component_name>.*)_(?<component_type>view|tab|pill|modal|panel)$/
      end

      # Inject components after loading dom, providing reader methods for
      # accessing them
      # @param names [Array<Symbol>] component names. Valid formats Regex:
      # /(?<component_name>.*)_(?<component_type>view|tab|pill|modal|panel)$/
      def component_reader(*names)
        names.each { |name| create_component_reader name }
        define_method :after_load_dom do
          load_components names
        end
      end

      def action_component_reader(*names)
        names.each { |name| load_action_component name }
      end

      private

      def create_component_reader(name)
        define_method name do
          instance_variable_get "@#{name}"
        end
      end

      # @param name [Symbol] name of the component. Valid formats Regex:
      #   /(?<component_name>.*)_(?<component_type>tab|pill|modal)$/
      def load_action_component(name)
        define_method name do
          component_for name
        end
      end
    end

    private

    # @param names [Array<Symbol>] list of names of the components.
    #   Valid formats Regex:
    #   /(?<component_name>.*)_(?<component_type>view|tab|pill|modal|panel)$/
    def load_components(names)
      @components ||= []
      names.each { |name| load_component name }
    end

    # @param name [Symbol] name of the component. Valid formats Regex:
    #   /(?<component_name>.*)_(?<component_type>view|panel)$/
    def load_component(name)
      component = component_for name
      instance_variable_set("@#{name}", component)
      @components << component
    end

    # @param name [Symbol] name of the component. Valid formats Regex:
    #   /(?<component_name>.*)_(?<component_type>view|tab|pill|modal|panel)$/
    def component_for(name)
      matches = self.class.component_method_regex.match(name)
      if matches
        send "#{matches[:component_type]}_for", matches[:component_name]
      else
        fail UnknownComponent
      end
    end
  end
end