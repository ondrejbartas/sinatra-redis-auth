# config.ru
require './example_app.rb'

# Map applications
run Rack::URLMap.new \
  "/"       => ExampleApp.new