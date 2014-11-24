Dir["#{File.dirname(__FILE__)}/selenium_record/*.rb"].each { |f| require f }

# Selenium Record provides objects for interacting with browser and managing
# the application during tests. Also joins in every object behaviour and
# expectations
module SeleniumRecord
end
