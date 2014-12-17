## 0.0.4

* Solved dependency reference error on load

## 0.0.3

* Fixed SeleniumRecord::Lookup::MatchingStrategy
* Renamed Lookup strategies for cleaner code
* Added Basic Documentation
* Added method `focus` to `SeleniumRecord::Actions` module

## 0.0.2.revision

* Updated `activesupport` dependency gem version

## 0.0.2

* Added rake task for scaffolding
* Added documentation for rake task
* Added `ComponentAutoload` module
* Added `cover` method in `SeleniumRecord::Actions` module for managing 
  `Selenium::WebDriver::Error::StaleElementReferenceError` when clicking 
  elements
* Added `Axiable` module to extend `Selenium::WebDriver::Element` when we call
  to `find` or `find_elements` methods
