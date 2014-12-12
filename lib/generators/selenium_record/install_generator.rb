require 'active_support/inflector'
require 'pry'

module SeleniumRecord
  module Generators
    # Generator for installing selenium record in project
    class InstallGenerator < Rails::Generators::Base
      desc 'Copy SeleniumRecord default files'
      source_root File.expand_path('../templates', __FILE__)
      class_option :objects_module, type: :string, default: 'SeleniumObjects',
                                    desc: 'Module containing selenium objects'
      class_option :test_framework, type: :string, default: 'rspec',
                                    desc: 'Test framework used'
      class_option :navigation_components, type: :array,
                                           default: %w(page tab),
                                           desc: 'Navigation components'

      def create_initializer_file
        template 'selenium_record.rb.erb',
                 'config/initializers/selenium_record.rb'
      end

      def create_base_dir
        empty_directory object_module_path
      end

      def create_common_components
        %w(page view).each { |c| create_component(c) }
      end

      def create_navigation_components
        options[:navigation_components].each { |c| create_component(c) }
      end

      def create_autoload
        @navigation_components = options[:navigation_components]
        @navigation_folders = @navigation_components.map do |component|
          ActiveSupport::Inflector.pluralize(component)
        end.join(' ')
        template 'autoload.rb.erb', File.join(object_module_path, 'autoload.rb')
      end

      private

      def create_component(component)
        om_path = object_module_path
        comp_folder = ActiveSupport::Inflector.pluralize(component)
        empty_directory File.join om_path, comp_folder
        @component_klass = ActiveSupport::Inflector.classify(component)
        template 'base/application_navigation_component.rb.erb',
                 File.join(om_path, 'base', "application_#{component}.rb")
      end

      def object_module_path
        om_name = options[:objects_module].to_s
        om_folder = ActiveSupport::Inflector.underscore(om_name)
        File.join destination_root, test_folder, om_folder
      end

      def test_folder
        case options[:test_framework]
        when 'rspec' then 'spec'
        when 'cucumber' then 'features'
        else
          'test'
        end
      end
    end
  end
end
