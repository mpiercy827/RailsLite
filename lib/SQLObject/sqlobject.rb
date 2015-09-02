require_relative 'db_connection'
require_relative 'options'
require 'active_support/inflector'

class SQLObject
  attr_accessor :id
  # Get names of the database columns
  def self.columns
    info = DBConnection.execute2("SELECT * FROM #{table_name}")
    titles = info.first #execute2 returns the column names as the first entry

    titles.map(&:to_sym)
  end

  # Create getter and setter methods for each of the columns in the database
  def self.finalize!
    columns.each do |col|
      define_method("#{col}") { attributes[col] }
      define_method("#{col}=") { |value| attributes[col] = value }
    end
  end

  # Set an instance variable for the name of the database table
  def self.table_name=(table_name)
    instance_variable_set("@table_name", table_name)
  end

  # If a table name is not provided, simply use the name of the class which
  # is inheriting from SQLObject
  def self.table_name
    @table_name ||= to_s.tableize
  end

  # Return all of the entries in the table
  def self.all
    hashes = DBConnection.execute(<<-SQL)
      SELECT #{table_name}.*
      FROM #{table_name}
    SQL

    parse_all(hashes)
  end

  # Turns the data from the database into SQLObjects
  def self.parse_all(results)
    results.map { |result| new(result) }
  end

  #Finds an element in the database with a given id.
  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT #{table_name}.*
      FROM #{table_name}
      WHERE #{table_name}.id = ?
    SQL

    result.empty? ? nil : new(result.first)
  end

  # Returns an array of models satisfying the given conditions.
  def self.where(params)
    where_line = params.keys.map { |attr| "#{attr} = ?" }.join(" AND ")
    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT *
      FROM #{table_name}
      WHERE #{where_line}
    SQL

    parse_all(results)
  end

  def initialize(params = {})
    params.each do |name, value|
      unless self.class.columns.include?(name.to_sym)
        raise "unknown attribute '#{name}'"
      end
      send("#{name}=", value)
    end
  end

  # Gets the attribute names of the model
  def attributes
    @attributes ||= {}
  end

  # Used to store and access has_many and belongs_to associations
  def assoc_options
    @assoc_options ||= {}
  end

  # Gets the attribute values of a model
  def attribute_values
    self.class.columns.map { |col| send(col) }
  end

  # Used when creating a new entry in the database
  def insert
    col_names = self.class.columns
    question_marks = Array.new(col_names.size) { "?" }.join(", ")
    col_names = col_names.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO #{self.class.table_name} (#{col_names})
      VALUES (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  # Updates an existing entry in the database
  def update
    set_line = self.class.columns.map { |attr| "#{attr} = ?"}.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE #{self.class.table_name}
      SET #{set_line}
      WHERE id = ?
    SQL
  end

  # Either creates or updates a row in the database depending on whether or not
  # if already exists.
  def save
    id.nil? ? insert : update
  end

  # Creates an association where this model belongs to another
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    assoc_options[name] = options

    define_method(name) do
      fk_value = send(options.foreign_key)

      options
        .model_class
        .where( options.primary_key => fk_value )
        .first
    end
  end

  # Creates an association where other models belong to this one.
  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)

    define_method(name) do
      pk_value = send(options.primary_key)

      options
        .model_class
        .where( options.foreign_key => pk_value )
    end
  end

  # Used for creating associations through other associations.
  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options  = through_options.model_class.assoc_options[source_name]

      thru_table = through_options.model_class.table_name
      thru_pk    = through_options.primary_key

      to_table  = source_options.model_class.table_name
      to_fk    = source_options.foreign_key
      to_pk    = source_options.primary_key

      results = DBConnection.execute(<<-SQL, id)
        SELECT #{to_table}.*
        FROM #{thru_table}
        JOIN #{to_table} ON #{thru_table}.#{to_fk} = #{to_table}.#{to_pk}
        WHERE #{thru_table}.#{thru_pk} = ?
      SQL

      source_options.model_class.parse_all(results).first
    end
  end
end
