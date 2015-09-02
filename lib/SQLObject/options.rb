class AssociationOptions
  attr_accessor :foreign_key, :class_name, :primary_key

  def model_class
    "#{class_name}".constantize
  end

  def table_name
    "#{class_name.underscore}s"
  end
end

#Used for belongs_to associations
class BelongsToOptions < AssociationOptions
  def initialize(name, options = {})
    defaults = {  primary_key: :id,
                  foreign_key: "#{name.to_s.underscore}_id".to_sym,
                  class_name: "#{name}".singularize.camelcase
               }
    options = defaults.merge(options)

    self.primary_key  = options[:primary_key]
    self.foreign_key  = options[:foreign_key]
    self.class_name   = options[:class_name]
  end
end

#Used for has_many associations
class HasManyOptions < AssociationOptions
  def initialize(name, self_class_name, options = {})
    defaults = {  primary_key: :id,
                  foreign_key: "#{self_class_name.underscore}_id".to_sym,
                  class_name: "#{name}".singularize.camelcase
               }
    options = defaults.merge(options)

    self.foreign_key  = options[:foreign_key]
    self.primary_key  = options[:primary_key]
    self.class_name   = options[:class_name]
  end
end
