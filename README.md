# capistrano-runit-cmd

Capistrano3 tasks for manage any command line programms via runit supervisor.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-runit-cmd'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-runit-cmd

## Tasks

* `runit:cmd:start` -- start all commands.
* `runit:cmd:stop` -- stop all commands.
* `runit:cmd:restart` -- restart all commands.
* `runit:cmd:foo:setup` -- setup `foo` command service.
* `runit:cmd:foo:enable` -- enable `foo` command service.
* `runit:cmd:foo:disable` -- disable `foo` commang service.
* `runit:cmd:foo:start` -- start `foo` commang service.
* `runit:cmd:foo:stop` -- stop `foo` commang service.

## Variables

* `runit_cmd_role` -- what host roles uses runit to run command. Default value: `:app`
* `runit_cmd_foo_role` -- what host roles uses runit to run command with key `foo`. Default value: `:app`
* `runit_cmds` -- Hash of commangs. Default value: `{}`

## Usage

Add this line in `Capfile`:
```ruby
require 'capistrano/runit/cmd'
```
Add your tasks in `config/deploy.rb`:

```ruby
set :runit_cmds, {
  'foo' => 'bundle exec gush workers'
}
set :runit_cmd_foo_role, :db # change role for foo commang
```

## Contributing

1. Fork it ( https://github.com/capistrano-runit/cmd/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
