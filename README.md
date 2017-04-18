# GraphQL::QueryResolver
[![Build Status](https://travis-ci.org/nettofarah/graphql-query-resolver.svg?branch=master)](https://travis-ci.org/nettofarah/graphql-query-resolver)

GraphQL::QueryResolver is an add-on to [graphql-ruby](https://github.com/rmosolgo/graphql-ruby)
that allows your field resolvers to minimize N+1 SELECTS issued by ActiveRecord.

GraphQL::QueryResolver will analyze the AST from incoming GraphQL queries and
try to match query selections to `ActiveRecord::Reflections` present in your
`ActiveRecord` models.

Every matched selection will be then passed on to
`ActiveRecord::Associations::Preloader.new` so your queries now only issue
one `SELECT` statement for every level of the GraphQL AST.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql-query-resolver'
```

And then execute:

  $ bundle

Or install it yourself as:

  $ gem install graphql-query-resolver

## Usage
```ruby
require 'graphql/query_resolver'

# In your field resolver
# Assuming `Project < ActiveRecord::Base` and a `ProjectType` GraphQL type:
#
field :projects do
  type types[ProjectType]

  resolve -> (obj, args, ctx) {
    # Wrap your field resolve operation with `GraphQL::QueryResolver`
    GraphQL::QueryResolver.run(Project, ctx, ProjectType) do
      Project.all
    end
  }
end

# QueryResolver works the same way for single objects

field :comment do
  type CommentType
  argument :id, !types.ID

  resolve -> (obj, args, ctx) {
    GraphQL::QueryResolver.run(Comment, ctx, CommentType) do
      Comment.find(args['id'])
    end
  }
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nettofarah/graphql-query-resolver. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

To run the specs across all supported versions of ActiveRecord, check out the repo and follow these steps:
```bash
$ bundle install
$ bundle exec appraisal install
$ bundle exec appraisal rake
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
