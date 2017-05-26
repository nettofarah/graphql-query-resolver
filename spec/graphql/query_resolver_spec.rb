require 'spec_helper'

describe GraphQL::QueryResolver do

  before(:each) do
    TestData.create_netto
  end

  it 'groups queries' do
    data = nil

    queries = track_queries do
      data = GQL.query(%{
        query {
          recipes {
            title
            ingredients { name }
          }
        }
      })
    end

    expect(queries.size).to eq(2)
    expect(queries.first).to eq('SELECT "recipes".* FROM "recipes"')
    expect(queries.last).to eq('SELECT "ingredients".* FROM "ingredients" WHERE "ingredients"."recipe_id" IN (1, 2, 3, 4)')
  end

  it 'works with multiple levels of nesting' do
    data = nil

    queries = track_queries do
      data = GQL.query(%{
        query {
          recipes {
            title
            ingredients {
              name, quantity
              vendor { name }
            }
          }
        }
      })
    end

    expect(queries.size).to eq(3)
    expect(queries[0]).to eq('SELECT "recipes".* FROM "recipes"')
    expect(queries[1]).to eq('SELECT "ingredients".* FROM "ingredients" WHERE "ingredients"."recipe_id" IN (1, 2, 3, 4)')
    expect(queries[2]).to eq('SELECT "vendors".* FROM "vendors" WHERE "vendors"."id" IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)')
  end

  it 'issues one SELECT call per level' do
    data = nil

    queries = track_queries do
      data = GQL.query(%{
        query {
          restaurant(id: 1) {
            name
            owner {
              name
              recipes {
                title
                ingredients {
                  name, quantity
                  vendor {
                    name
                  }
                }
              }
            }
          }
        }
      })
    end


    expect(queries[0]).to include('SELECT "restaurants".* FROM "restaurants" WHERE "restaurants"."id" = ?')
    expect(queries[1]).to include('SELECT "chefs".* FROM "chefs" WHERE "chefs"."id"') # AR 4 will use id IN (1), AR 5 will use id = 1
    expect(queries[2]).to include('SELECT "recipes".* FROM "recipes" WHERE "recipes"."chef_id"') # AR 4 will use id IN (1), AR 5 will use id = 1
    expect(queries[3]).to include('SELECT "ingredients".* FROM "ingredients" WHERE "ingredients"."recipe_id" IN (1, 2, 3, 4)')
    expect(queries[4]).to include('SELECT "vendors".* FROM "vendors" WHERE "vendors"."id" IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)')
  end

  it 'works with alias reflections' do
    # Owner is an instance of Chef
    query = %{
      query {
        restaurant(id: 1) {
          name
          owner { name }
        }
      }
    }

    queries = track_queries do
      GQL.query(query)
    end

    expect(queries.size).to eq(2)
  end

  it 'works with pagination' do
    query = %{
      query {
        vendors(first: 5) {
          edges {
            node {
              id
              name
              ingredients {
                name
                quantity
              }
            }
            cursor
          }
          pageInfo {
            hasNextPage
          }
        }
      }
    }
    queries = track_queries do
      GQL.query(query)
    end

    expect(queries.size).to eq(2)
  end
end
