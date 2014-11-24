module SeleniumRecord
  # Contains helper methods for translations
  module Translations
    # @param key [String] the key to be used to lookup text translations
    # @return [String] the translation for the given key
    def trans(key)
      I18n.t(key)
    end
  end
end
