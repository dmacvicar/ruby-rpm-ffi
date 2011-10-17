$: << File.join(File.dirname(__FILE__), "..", "lib")
require 'test/unit'
require 'rpm'

def fixture(name)
  File.join(File.dirname(__FILE__), 'data', name)
end