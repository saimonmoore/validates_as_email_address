if Object.const_defined?(:I18n) # Rails >= 2.2
  I18n.load_path << File.dirname(__FILE__) + '/locales/en.yml'
end
require 'validates_as_email_address'