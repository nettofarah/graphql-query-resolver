require 'spec_helper'

describe GraphQL::QueryResolver do

  before(:each) do
    TestData.create_netto
  end

  it 'does something useful' do
    data = nil

    queries = track_queries do
      data = GQL.query(%{
        query {
          recipes {
            #title

            ingredients {
              name
              #vendor { name }
            }
         }
        }
      })
    end

    puts queries

    expect(true).to eq(true)
  end
end
