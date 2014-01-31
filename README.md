# Heroics

Ruby HTTP client for APIs represented with JSON schema.

## Installation

Add this line to your application's Gemfile:

    gem 'heroics'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install heroics

## Usage

### Generate a client from a JSON schema

Heroics generates an HTTP client from a JSON schema.  The simplest way
to get started is to provide the URL to the schema you want to base
the client on:

```ruby
require 'cgi'
require 'heroics'

username = CGI.escape('username')
token = 'token'
url = "https://#{username}:#{token}@api.heroku.com/schema"
options = {default_headers: {'Accept' => 'application/vnd.heroku+json; version=3'}}
client = Heroics.client_from_schema_url(url, options)
```

The client will make requests to the API using the credentials from
the URL.  The default headers will also be included in all requests
(including the one to download the schema and all subsequent
requests).

You can also create a client from an in-memory schema object:

```ruby
require 'cgi'
require 'json'
require 'heroics'

username = CGI.escape('username')
token = 'token'
url = "https://#{username}:#{token}@api.heroku.com/schema"
options = {default_headers: {'Accept' => 'application/vnd.heroku+json; version=3'}}
data = JSON.parse(File.read('schema.json'))
schema = Heroics::Schema.new(data)
client = Heroics.client_from_schema(schema, url, options)
```

### Client-side caching

Heroics handles ETags and will cache data on the client if you provide
a [Moneta](https://github.com/minad/moneta) cache instance.

```ruby
username = 'username'
token = 'token'
url = "https://#{username}:#{token}@api.heroku.com/schema"
options = {default_headers: {'Accept' => 'application/vnd.heroku+json; version=3'},
           cache: Moneta.new(:File, dir: "#{Dir.home}/.heroics/heroku-api")}
client = Heroics.client_from_schema_url(url, options)
```

### Making requests

The client exposes resources as top-level methods.  Links described in
the JSON schema for those resources are represented as methods on
those top-level resources.  For example, you can [list the apps](https://devcenter.heroku.com/articles/platform-api-reference#app-list)
in your Heroku account:

```ruby
apps = client.app.list
```

The response received from the server will be returned without
modifications.  Response content with type `application/json` is
automatically decoded into a Ruby object.

### Handling content ranges

Content ranges are handled transparently.  In such cases the client
will return an `Enumerator` that can be used to access the data.  It
only makes requests to the server to fetch additional data when the
current batch has been exhausted.

### Command-line interface

Heroics includes a builtin CLI that, like the client, is generated
from a JSON schema.

```ruby
username = 'username'
token = 'token'
url = "https://#{username}:#{token}@api.heroku.com/schema"
options = {
  default_headers: {'Accept' => 'application/vnd.heroku+json; version=3'},
  cache: Moneta.new(:File, dir: "#{Dir.home}/.heroics/heroku-api")}
cli = Heroics.cli_from_schema_url('heroku-api', STDOUT, url, options)
cli.run(*ARGV)
```

Running it without arguments displays usage information:

```
$ bundle exec bin/heroku-api
Usage: heroku-api <command> [<parameter> [...]] [<body>]

Help topics, type "heroku-api help <topic>" for more details:

  account-feature:info          Info for an existing account feature.
  account-feature:list          List existing account features.
  account-feature:update        Update an existing account feature.
  account:change-email          Change Email for account.
  account:change-password       Change Password for account.
  account:info                  Info for account.
  account:update                Update account.
  addon-service:info            Info for existing addon-service.
  addon-service:list            List existing addon-services.
  addon:create                  Create a new add-on.
--- 8< --- snip --- 8< ---
```

Use the `help` command to learn about commands:

```
$ bundle exec bin/heroku-api help app:create
Usage: heroku-api app:create <body>

Description:
  Create a new app.

Body example:
  {
    "name": "example",
    "region": "",
    "stack": ""
  }
```

In addition to being a fun way to play with your API it also gives you
the basic information you need to use the same command from Ruby:

```ruby
client.app.create({'name'   => 'example',
                   'region' => '',
                   'stack'  => ''})
```

### Command arguments

Commands that take arguments will list them in help output from the
client.

```
$ bundle exec bin/heroku-api help app:info
Usage: heroku-api app:info <id|name>

Description:
  Info for existing app.
```

This command needs an app's UUID or name:

```ruby
info = client.app.info('sushi')
```

Some commands need arguments as well as a body.  In such cases, pass
the arguments first with the body at the end.

### Using the Heroku API

Heroics comes with a builtin `heroku-api` program that serves as an
example and makes it easy to play with the [Heroku Platform API](https://devcenter.heroku.com/articles/platform-api-reference).

### Handling failures

The client uses [Excon](https://github.com/geemus/excon) under the hood and raises Excon errors when
failures occur.

```ruby
begin
  client.app.create({'name' => 'example'})
rescue Excon::Errors::Forbidden => e
  puts e
end
```

## Contributing

1. [Fork the repository](https://github.com/heroku/heroics/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new pull request
