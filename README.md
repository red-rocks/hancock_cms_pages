# HancockCmsPages

### Remaded from [EnjoyCMSPages](https://github.com/enjoycreative/enjoy_cms_pages)

Menu([Simple Navigation](https://github.com/codeplant/simple-navigation)), pages and html blocks for [HancockCMS](https://github.com/red-rocks/hancock_cms).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hancock_cms_pages'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hancock_cms_pages

## Usage

Add in config/routes.rb

```ruby
  hancock_cms_pages_routes
```

Recommendation: add this line at the end fo routes.rb.
This method has route
```ruby
get '*slug'
```
so all requests will go here.
[More](https://github.com/red-rocks/hancock_cms_pages/blob/master/lib/hancock/pages/routes.rb)

Then execute

    $ rails g hancock:goto:config

and now you can edit config/initializers/hancock_pages.rb

### Views
Render navigation for blockset with name 'main':
```ruby
render_navigation &blockset_navigation(:main)
```
Render blockset(set of blocks which can have html code, partials or files) with name 'main':
```ruby
render_blockset(self, :main)
```
Render navigation menu with name 'main':
```ruby
render_navigation &navigation(:main)
```
[More](https://github.com/red-rocks/hancock_cms_pages/tree/master/app/controllers/concerns/hancock/pages)

### Localization

Add to application_controller.rb:

```ruby
class ApplicationController < ActionController::Base
  include Hancock::Controller
  include Hancock::Pages::Localizeable
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/red-rocks/hancock_cms_pages.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
