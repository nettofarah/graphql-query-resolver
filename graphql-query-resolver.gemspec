# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphql/query_resolver/version'

Gem::Specification.new do |spec|
  spec.name          = "graphql-query-resolver"
  spec.version       = GraphQL::QueryResolver::VERSION
  spec.authors       = ["nettofarah"]
  spec.email         = ["nettofarah@gmail.com"]

  spec.summary       = %q{GraphQL::QueryResolver is an add-on to graphql-ruby that allows your field resolvers to minimize N+1 SELECTS issued by ActiveRecord. }
  spec.homepage      = "https://github.com/nettofarah"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "graphql"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "activerecord", ">= 3.2"
  spec.add_development_dependency "sqlite3", "~> 1.3.12"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "byebug"

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
