require 'heroics'

Heroics.default_configuration do |config|
  config.base_url = 'https://example.com'
  config.module_name = 'ExampleClient'
  config.schema = 'schema.json'

  config.headers = 'Accept: application/vnd.example+json; version=1'
end
