## About Ruborm

Ruborm is a simple, light-weight object-relational mapping built in Ruby for SQLite3.

I built Ruborm as an exercise to try and develop a deeper understanding of the inner workings of ActiveRecord.  

Its main features are as follows:

- A two-way mapping between Ruby model instances and database provides full support for normal CRUD operations.
- The ability to run basic SQL queries using built-in methods (`::all`, `::find`, `::where`, etc.) on Ruby model classes.
- Custom association generators (`::belongs_to`, `::has_many`, `::has_one_through`, `::has_many_through`), with sensible default parameters.

## Defining a Model Class

Classes that use Ruborm should inherit from SQLObject.  Model classes should invoke `::finalize!` as in the example below.  This method instantiates all the setter and getter methods needed by the model class to map to the appropriate database records and columns.

```ruby
class Town < SQLObject
  finalize!
end
```

Note, model classes and database tables must be named according to the following rules:
- table names must be lower-case, snake_case, and plural, e.g. `cat_feet`
- model names must be upper-case, CamelCase, and singular, e.g. `CatFoot`

## Built-in Query Methods

Ruborm comes with several built-in methods to help make the normal tasks of database manipulation easy.

### `all` and `count`

`::all` is equivalent to `SELECT * from [table_name]`.  It returns an array of model instances, each encoded with column names and values as instance variables.

`::count` is equivalent to `SELECT COUNT(*) from [table_name]` and returns the total number of records in the associated table.

### `find`
`::find(id)` returns the record in the current table where `id`, an integer, matches the `primary_key`.

### `where` and `where_not`
`::where(params_hash)` and `::where_not` take a series of one or more key-value pairs, mapping the keys (symbols) to equivalent column names, and inserting the values as parameters within the SQL query.  For example:

```ruby
User.where_not(city: "Chicago", last_name: "Jones")
```
is equivalent to:
``` SQL
SELECT * FROM users
WHERE NOT city = 'Chicago' AND NOT last_name = 'Jones'
```

### `first` and `last`

Ruborm also offers the convenience methods `::first` and `::last`, which return the first and last records in the associated table, by their `id` column.

## Associations
Association generators in Ruborm are analogous to their equivalents in ActiveRecord, with some minor exceptions.  

### `belongs_to` and `has_many`
`has_many` and `belongs_to` associations are created using the eponymous generators, which take the name of the desired association (a symbol), and an optional options hash.  Sensible defaults are provided.
``` ruby
class Town < SQLObject
  has_many :citizens,
  foreign_key: :town_id,
  primary_key: :id,
  class_name: :Citizen

  finalize!
end

class Citizen < SQLObject
  # because defaults are provided by Ruborm
  # additional parameters are unnecessary,
  # when table and column names follow convention
  belongs_to :town

  finalize!
end

```

### `through` Associations
Ruborm provides two generators for compounded associations: `has_one_through` and `has_many_through`, which create one-to-one and one-to-many associations, respectively.

Both association generators take ordered parameters, which should be symbols, representing:

- the method name of the desired association (`:name`),
- the name of the association in the current model that is being exploited to achieve the through association (`:through_name`),
- the name of the association in the intermediate model, which targets the endpoint of the association (`:source_name`).

``` ruby
class Employee < SQLObject
  has_many_through(:sales, :customers, :purchases)
end
```

## Trying Out Ruborm

Setting up and using Ruborm is easy.  Here's how to get started.

First, clone the repo to your local machine.  If you want to use Ruborm with your own database, you should start by customizing `lib/db_connection.rb` to point to your SQLite database files. The default is to point to the cat database included in the repo and referenced in the tests.  

To experiment, simply fire up PRY or the Ruby REPL of your choice from inside the repo, `load 'lib/ruborn.rb'`, and start defining your database model classes.  The following code will get you up and running with the sample database:

``` ruby
load 'lib/ruborm.rb'

class Cat < SQLObject
  belongs_to :human, foreign_key: :owner_id
  has_many :toys
  finalize!
end

class Human < SQLObject
  self.table_name = 'humans' ## Ruborm has trouble pluralizing 'human'
  has_many :cats, foreign_key: :owner_id
  belongs_to :house
  has_many_through :toys, :cats, :toys
  finalize!
end

class Toy < SQLObject
  belongs_to :cat
  finalize!
end

```

Once you've defined the associations and model classes, you're ready to start pulling data from your database!  Try out a few of  the following commands to see Ruborm in action:

``` ruby
Cat.all
Human.first
Cat.last.toys
Human.first.toys
Human.find(2)
Cat.where(name: "Breakfast")
Human.last.toys.count
```
