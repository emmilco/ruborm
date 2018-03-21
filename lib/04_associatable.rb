require_relative '03_assoc_options'
require 'byebug'

module Associatable
  def has_many_through(name, through_name, source_name)
    define_method(name.to_sym) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_table = through_options.model_class.table_name
      source_table = source_options.model_class.table_name

      data = DBConnection.execute(<<-SQL)
        SELECT
          #{source_options.model_class.table_name}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_options.primary_key} = #{source_table}.#{source_options.foreign_key}
        WHERE
          #{through_table}.#{through_options.foreign_key} = #{self.send(through_options.primary_key)}
      SQL

      data.map { |datum| source_options.model_class.new(datum) }
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method(name.to_sym) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_table = through_options.model_class.table_name
      source_table = source_options.model_class.table_name

      data = DBConnection.execute(<<-SQL)
        SELECT
          #{source_options.model_class.table_name}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_options.foreign_key} = #{source_table}.#{source_options.primary_key}
        WHERE
          #{through_table}.#{through_options.primary_key} = #{self.send(through_options.foreign_key)}
      SQL

      data.map { |datum| source_options.model_class.new(datum) }.first
    end
  end
end
