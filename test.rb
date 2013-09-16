require 'netrc'

_, token = Netrc.read['api.heroku.com']

require './lib/heroics'

heroics = Heroics.new(
  :cache => Heroics::FileCache.new(token),
  :token => token
)

heroics.apps.list
apps = heroics.apps.list # should use cache
puts(apps)
puts

app = heroics.apps.info('stringer-geemus')
puts(app)
puts

puts(heroics.apps('stringer-geemus'))
puts

collaborators = app.collaborators.list
puts(collaborators)
puts

collaborator_id = collaborators.first.id
collaborator = app.collaborators.info(collaborator_id)
puts(collaborator)
puts

puts(heroics.collaborator('stringer-geemus', collaborator_id))

regions = heroics.regions.list
puts(regions)
puts

region_id = regions.first.id
puts(heroics.regions.info(region_id))
puts

puts(heroics.region(region_id))
puts
