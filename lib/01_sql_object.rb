require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.finalize!
    self.columns.each do |col|
      define_method(col) { attributes[col] }
      define_method("#{col}=".to_sym) { |val| attributes[col] = val }
    end
  end

  def self.table_name=(table_name)
    if table_name
      @table_name = table_name
    else
      @table_name = self.name.tableize
    end
  end

  def self.table_name
    @table_name ||= self.name.tableize
  end

  def self.columns
    return @columns if @columns
    data = DBConnection.execute2(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL

    @columns = data[1].keys.map(&:to_sym)
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT #{self.table_name}.*
      FROM #{self.table_name}
    SQL
    self.parse_all(data)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL)
      SELECT *
      FROM "#{self.table_name}"
      WHERE id = #{id}
    SQL
    data.empty? ? nil : self.new(data[0])
  end

  def initialize(params = {})
    params.each do |col, val|
      raise "unknown attribute '#{col}'" unless self.class.columns.include?(col.to_sym)
      self.send("#{col}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |col| self.send(col) }
  end

  def insert
    question_marks = "(#{Array.new(self.class.columns.length - 1, '?').join(', ')})"
    column_names = "(#{self.class.columns[1..-1].join(', ')})"

    DBConnection.execute(<<-SQL, *self.attribute_values[1..-1])
      INSERT INTO
      #{self.class.table_name} #{column_names}
      VALUES
      #{question_marks}
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    cols = self.class.columns[1..-1].map { |col| "#{col} = ?" }.join(", ")
    DBConnection.execute(<<-SQL, *self.attribute_values[1..-1])
      UPDATE
      #{self.class.table_name}
      SET
      #{cols}
      WHERE
      id = #{self.id}
    SQL
  end

  def save
    self.id ? self.update : self.insert
  end
end
