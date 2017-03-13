module TestData

  def self.nv(name)
    Vendor.new(name: name)
  end

  def self.create_netto
    Chef.create(name: 'Netto', email: 'nettofarah@gmail.com').tap do |netto|

      Recipe.create(title: 'Turkey Sandwich', chef: netto).tap do |r|
        r.ingredients.create(name: 'Turkey', quantity: 'a lot', vendor: nv('Turkey Farm'))
        r.ingredients.create(name: 'Cheese', quantity: '1 slice', vendor: nv('Dairy Farm'))
        r.ingredients.create(name: 'Bread', quantity: '1 loaf', vendor: nv('Bakery'))
        r.ingredients.create(name: 'Mayo', quantity: '1 spoon', vendor: nv('Costco'))
      end

      Restaurant.create(name: "Netto's Joint", owner: netto)

      Recipe.create(title: 'Cheese Burger', chef: netto).tap do |r|
        r.ingredients.create(name: 'Patty', quantity: '1', vendor: nv('Butcher'))
        r.ingredients.create(name: 'Cheese', quantity: '2 slices', vendor: nv('Berkeley Farms'))
      end

      Recipe.create(title: 'Bacon Cheese Burger', chef: netto).tap do |r|
        r.ingredients.create(name: 'Patty', quantity: '1', vendor: nv('Butcher'))
        r.ingredients.create(name: 'Cheese', quantity: '2 slices', vendor: nv('Somewhere'))
        r.ingredients.create(name: 'Bacon', quantity: '2 slices', vendor: nv('Heaven'))
      end

      Recipe.create(title: 'BBQ Burger', chef: netto).tap do |r|
        r.ingredients.create(name: 'Patty', quantity: '1', vendor: nv('Costco'))
        r.ingredients.create(name: 'BBQ Sauce', quantity: '1 spoon', vendor: nv('Somewhere in SC'))
      end
    end

    Person.create(name: 'John Doe')
  end
end
