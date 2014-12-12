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

- [ ] Full test coverage
- [ ] Wiki and README Documentation
- [X] Basic install generator
- [X] ComponentAutoload integration in core (Currently present as a framework
    extension)

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
