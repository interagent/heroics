# Heroics

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'heroics'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install heroics

## Usage

TODO: Write usage instructions here

The interface is designed to match the workings of the (Heroku Platform API)[https://devcenter.heroku.com/articles/platform-api-reference].

```
heroics = Heroics.new(token: ENV['HEROKU_API_TOKEN'])

# apps
heroics.apps.create(name: 'example')  # returns new app named 'example'
heroics.apps.list                     # returns list of all apps
heroics.apps.info('example')          # returns app with id or name of 'example'

app = heroics.apps('example')       # returns local reference to app with id or name 'example'
app.update(name: 'rename')          # returns updated app
app.delete                          # returns deleted app

# addons
app = heroics.apps('example')                               # returns local reference to app with id or name 'example'
app.addons.create(plan: { name: 'heroku-postgresql:dev' })  # returns new add-on with plan:name 'heroku-postgresql:dev'
app.addons.list                                             # returns list of all add-ons for app with id or name of 'example'

addon = app.addons.info('heroku-postgresql:dev')            # returns add-on with id or name 'heroku-postgresql:dev'
addon.update(plan: { name: 'heroku-postgresql:basic' })     # returns updated add-on
addon.delete                                                # returns deleted add-on
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
