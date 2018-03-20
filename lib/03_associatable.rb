require 'byebug'
require_relative '02_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    self.model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name  = options[:class_name]  || "#{name}".capitalize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name.downcase.underscore}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name  = options[:class_name]  || "#{name}".singularize.camelcase
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    foreign_key_symbol = options.foreign_key

    define_method(name.to_sym) do
      options.model_class.where(id: self.send(foreign_key_symbol)).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    foreign_key_symbol = options.foreign_key

    define_method(name.to_sym) do
      options.model_class.where(foreign_key_symbol => self.id)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
