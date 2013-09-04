require 'netrc'

_, token = Netrc.read['api.heroku.com']

require './lib/heroics'

heroics = Heroics.new(:token => token)

heroics.apps.list
apps = heroics.apps.list # should use cache
puts(apps)
puts

app = heroics.apps.info('stringer-geemus')
puts(app)
puts

addons = app.addons.list
puts(addons)
puts

addon_id = addons.first.attributes[:id]
addon = app.addons.info(addon_id)
puts(addon)
puts
