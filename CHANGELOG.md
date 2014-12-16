## 0.0.2

* Added rake task for scaffolding
* Added `cover` method in `SeleniumRecord::Actions` module for managing 
  `Selenium::WebDriver::Error::StaleElementReferenceError` when clicking 
  elements
* Added `Axiable` module to extend `Selenium::WebDriver::Element` when we call
  to `find` or `find_elements` methods
* Added `ComponentAutoload` module
