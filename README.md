# About Ruborm

Ruborm is a simple, light-weight ORM built in Ruby for SQLite3.

I built Ruborm as an exercise to try and develop a deeper understanding of the inner workings of ActiveRecord.  

Its main features are as follows:

- A two-way mapping between Ruby model instances and database provides full support for normal CRUD operations.
- The ability to run SQL queries using simple methods (`#all`, `#find`, `#where`, etc.) on Ruby model class instances.
- Model-level association generators (`::belongs_to`, `::has_many`, `::has_one_through`, `::has_many_through`), with sensible default parameters.

## Setting up Ruborm

If you want to use Ruborm with your own database, you should start by customizing `lib/db_connection.rb` to point to your database. The default is to point up to the cat database included in the repo and referenced in the tests.  
