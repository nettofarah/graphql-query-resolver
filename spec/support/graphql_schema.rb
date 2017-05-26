require 'graphql'
require 'graphql/query_resolver'

RestaurantType = GraphQL::ObjectType.define do
  name "restaurant"

  field :id, types.ID
  field :name, types.String

  field :owner do
    type ChefType

    resolve -> (obj, args, ctx) {
      obj.owner
    }
  end

  field :recipes do
    type types[RecipeType]

    resolve -> (obj, args, ctx) {
      obj.owner.recipes
    }
  end
end

ChefType = GraphQL::ObjectType.define do
  name "chef"

  field :id, types.ID
  field :name, types.String
  field :email, types.String

  field :recipes do
    type types[RecipeType]

    resolve -> (obj, args, ctx) {
      obj.recipes
    }
  end
end

RecipeType = GraphQL::ObjectType.define do
  name "recipe"

  field :id, types.ID
  field :title, types.String

  field :ingredients do
    type types[IngredientType]

    resolve -> (obj, args, ctx) {
      obj.ingredients
    }
  end
end

VendorType = GraphQL::ObjectType.define do
  name "vendor"

  field :id, types.ID
  field :name, types.String

  field :ingredients do
    type types[IngredientType]

    resolve -> (obj, args, ctx) {
      obj.ingredients
    }
  end
end

IngredientType = GraphQL::ObjectType.define do
  name "ingredient"

  field :id, types.ID
  field :name, types.String
  field :quantity, types.Int
  field :vendor, VendorType
end

QueryRoot = GraphQL::ObjectType.define do
  name "query"
  description "The top level query"

  field :recipes do
    type types[RecipeType]

    resolve -> (obj, args, ctx) {
      GraphQL::QueryResolver::run(Recipe, ctx, RecipeType) do
        Recipe.all
      end
    }
  end

  field :restaurant do
    type RestaurantType
    argument :id, !types.Int

    resolve -> (obj, args, ctx) {
      id = args['id']

      GraphQL::QueryResolver::run(Restaurant, ctx, RestaurantType) do
        Restaurant.find(id)
      end
    }
  end

  connection :vendors, VendorType.connection_type, max_page_size: 50 do
    resolve -> (obj, args, ctx) {
      GraphQL::QueryResolver::run(Vendor, ctx, VendorType) do
        Vendor.all.to_a
      end
    }
  end
end

Schema = GraphQL::Schema.define do
  query QueryRoot
end

class GQL

  class QueryError < StandardError; end

  def self.query(query_string)
    document = GraphQL.parse(query_string)

    result = Schema.execute({
      document: document
    })

    if result['errors'].present?
      raise QueryError.new(result['errors'])
    end

    result['data']
  end
end
