[![Gem Version](https://badge.fury.io/rb/seleniumrecord.svg)](http://badge.fury.io/rb/seleniumrecord)
[![Code Climate](https://codeclimate.com/github/dsaenztagarro/selenium-record/badges/gpa.svg)](https://codeclimate.com/github/dsaenztagarro/selenium-record)

# SeleniumRecord

Selenium Record is a DSL for easily writing acceptance tests. It is a wrapper 
over Selenium ruby bindings to let you easily apply the well known page object 
pattern.

## Why to use

Within your web app's UI there are areas that your tests interact with. A
Selenium Record object simply models these as objects within the test code.
This reduces the amount of duplicated code and means that if the UI changes,
the fix need only be applied in one place.

## Rake tasks

**selenium_record:install**

Generates scaffolding for selenium objects

```shell
bundle exec rake selenium_record:install --test_framework=rspec
```

Options:
- 'test_framework': [String] Test framework to use. Possible values: 'rspec', 
  'cucumber', 'test_unit'. 
- 'object_module': [String] Base module for selenium objects. 
  Default: 'SeleniumObject'
- 'navigation_components': [Array] The names of the navigation components 
  expected. Default: ['pages', 'tab']

## Usage

### Lookup strategy

Everytime you create a Selenium object it is fired the lookup process. This mean
that based on selected strategy is defined the value for `root_el` (an instance
of `Selenium::WebDriver::Element`). What really matters about this is that all
`find_element` or `find_elements` operations will be done always in the scope
of the `root_el`.

#### Hooks

The lookup process defines two hooks:

- before_load_dom: This hook allows you to do some actions before the lookup
  process. For example, `SeleniumRecord::NavigationItem` takes this hook to
  click on a menu page and start lookup only once the new page it is loaded.

- after_load_dom: This hook allows you to do some actions after lookup process.
  For example, `SeleniumRecord::Base` takes this hook to inject components
  defined.

```ruby
# selenium_record/component_autoload.rb

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
```

**REMEMBER:** All selenium objects should define their lookup strategy through
the class method `lookup_strategy`.

#### Relative title

In the next example it is search in first place element relative to element for
locator returned by `title_locator` instance method. Once found this element 
it is searched the `root_el` using a relative xpath.

```ruby
# spec/support/selenium_objects/panels/image_panel.rb
module SeleniumObjects
  module Panels
    # Selenium Page Object to interact with areas sections for a page
    class ImagePanel < Base::ApplicationView
      lookup_strategy :relative_title, locator: { xpath: '../../..' }
      
      # ...
```

#### Matching element

This strategy searchs exactly for the element which the locator passed as
parameter.

```ruby
# spec/support/selenium_objects/panels/image_panel.rb
module SeleniumObjects
  module Panels
    # Selenium Page Object to interact with areas sections for a page
    class ImagePanel < Base::ApplicationView
      lookup_strategy :matching, locator: { xpath: ".//div[@class='todo-list']" }
      # ...
```


#### Root

This strategy sets as `root_el` the element associated with html `body` tag

```ruby
module SeleniumRecord
  # Base model to be extended by all Selenium page objects
  class NavigationItem < Base
    lookup_strategy :root
    # ...
```

### Dependency injection

When you call `component_reader` class method you pass a list of components that
will be injected into the current component once it is instantiated. They will
be available through the related accessor methods (Example: `filter_panel`).

#### Components

```ruby
# spec/support/selenium_objects/panels/search/filter_panel
module SeleniumObjects
  module Panels
    class FilterPanel < Base::ApplicationPanel
      # ...
      def search
        # Do search stuff
      end

# spec/support/selenium_objects/views/search_view
module SeleniumObjects
  module Views
    class SearchView < Base::ApplicationView
      navigate_to :labels
      component_reader :filter_panel, :results_panel
# ...
```

In addition all method calls to instance methods of components will be proxied
through the container component if this component doesn't define the proper
method. In the previous example:

```ruby
search_view # => SearchView instance
search_view.search  # => equal to search_view.filter_panel.search
```

#### Action components

When you call `action_component_reader` class method you can pass a list of
components that will perform an action once they are instantiated. Because of
that, when you create an instance of `ConceptView` it will be generated only
the accessors methods to create the related instance of `DetailsTab` (equal to
other tabs).

As `DetailsTab` is a component of `ConceptView`, the attribute `parent_el` of
`DetailsTab` will match the `root_el` of `ConceptView`.

```ruby
# spec/support/selenium_objects/tabs/details_tab
module SeleniumObjects
  module Tabs
    class DetailsTab < Base::ApplicationView
      navigate_to :details

# spec/support/selenium_objects/views/concept_view.rb
module SeleniumObjects
  module Views
    class ConceptView < Base::ApplicationView
      lookup_strategy :root
      action_component_reader :main_tab, :details_tab, :audit_tab

```

If we focus on `DetailsTab`:

```ruby
    class DetailsTab < Base::ApplicationView
      navigate_to :details
```

The method `navigate_to` will perform a click on link with localized string 
"details".

Of course you can customize to fit your needs this approach using a code like
this one. In the next example we change from expected `trans key` to 
`trans "txt.views.layouts.sections.#{key}"`

```ruby
# spec/support/selenium_objects/base/application_tab.rb
module SeleniumObjects
  module Base
    # Base class for all selenium objects representing an application tab
    class ApplicationTab < ::SeleniumRecord::NavigationItem

      def self.navigate_to(key)
        define_method :before_navigate do
          @title = trans "txt.views.layouts.sections.#{key}"
        end
      end

      # ...
```

### Scopes

Scopes allow you to execute code inside a block in the scope of the 
`Selenium::WebDriver::Element` associated to the scope definition. To define
a scoped block you use the syntax: `scope :my_symbol { #stuff }`.
The code will be executed in the context of the element with locator defined
through method `my_symbol_locator`.

#### Using locator symbol

```ruby
# spec/support/selenium_objects/views/concept_view.rb
module SeleniumObjects
  module Views
    class ConceptView < Base::ApplicationView
      lookup_strategy :root

      def create_new_version
        scope :fieldset_relations do
          # Methods from Actions module are executed relative to the element
          # specified by fieldset_relations_locator
          # See `selenium_record/actions` for more details
        end
      end

      def fieldset_relations_locator
        { xpath: ".//div[@class='relations']"
      end
      
      # ...
```

#### Extensions

Everytime you call methods like `find` or `find_elements`, it will be returned
the `Selenium::WebDriver::Element` instances with methods from modules:

- `SeleniumRecord::Axiable`

**WARNING**: Currently this behaviour it is only implemented for `find`

#### Plugins

As a good practice, all stuff related to a explicit javascript library should
be package inside plugins folder. As an example:

```
# spec/support/selenium_objects/plugins/jquery_autocomplete.rb
module SeleniumObjects
  module Plugins
    class JQueryAutocomplete < ::SeleniumRecord::Base
      attr_accessor :input_el
      # @param browser [Selenium::WebDriver::Driver]
      # @param locator [Hash] The locator of the input text autocomplete element
      def initialize(browser, locator)
        @root_el = browser
        @input_el = find(locator)
      end

      def perform(text)
        @text = text
        search_text
        select_from_pulldown_menu
        wait_for_tag_created
      end

      # ...
```

## Install

After running `rake selenium_record::install`, you should include a module in
Rspec with:

```ruby
module SeleniumRecordHelpers
  def browser
    @browser ||= page.driver.browser
  end

  def create_page(page_sym)
    klass = page_sym.to_s.camelize
    "SeleniumObjects::Pages::#{klass}Page".constantize.new(browser).load_dom!
  end
end
```

## Warning

This gem is still under development! As this gem was born while I was trying to
right acceptance tests in a more maintainable and productive way, it is not 
already tested!! Check the roadmap for upcoming updates. All pending tasks 
should be completed for '1.0.0' version. Keep up to date!

## Roadmap

SeleniumRecord is on its way towards 1.0.0. Please refer to 
[issues](https://github.com/dsaenztagarro/selenium-record/issues) for details.

## Installation

Add this line to your application's Gemfile:

    gem 'seleniumrecord'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install seleniumrecord

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/dsaenztagarro/selenium-record/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## References

- [Selenium Wiki Page](https://code.google.com/p/selenium/wiki/PageObjects)
- "Selenium 2 Testing Tools" by David Burns

## Thanks

Thanks to [Hola Internet](https://github.com/holadev) for let me right this kind of tools
