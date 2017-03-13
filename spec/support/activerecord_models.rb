class Recipe < ActiveRecord::Base
  belongs_to :chef
  has_many :ingredients #, through: :recipes_ingredients

  serialize :metadata, JSON
end

class Ingredient < ActiveRecord::Base
  belongs_to :vendor
end

class Vendor < ActiveRecord::Base
  has_many :ingredients
end

class Restaurant < ActiveRecord::Base
  belongs_to :owner, class_name: 'Chef'
  has_one :rating
end

class Rating < ActiveRecord::Base
  belongs_to :restaurant
end

class Chef < ActiveRecord::Base
  has_many :recipes
  has_many :ingredients, through: :recipes
  has_one  :restaurant, foreign_key: 'owner_id'
end

class Person < ActiveRecord::Base
  self.primary_key = :ssn
end
