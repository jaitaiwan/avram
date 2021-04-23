module Avram::UniqueColumns
  macro unique_columns(*attribute_names)
    def self.find_or_create!(*args, **named_args) : T
      operation = new(*args, **named_args)
      existing_record = find_existing_unique_record(operation)

      if existing_record
        existing_record
      else
        operation.save!
      end
    end

    def self.upsert!(*args, **named_args)
      operation = new(*args, **named_args)
      existing_record = find_existing_unique_record(operation)

      if existing_record
        operation.record = existing_record
        operation.save!
      else
        operation.save!
      end
    end

    def self.find_existing_unique_record(operation) : T?
      T::BaseQuery.new
        {% for attribute in attribute_names %}
          .{{ attribute.id }}.nilable_eq(operation.{{ attribute.id }}.value)
        {% end %}
        .first?
    end
  end

  # :nodoc:
  macro included
    {% for method in ["find_or_create!", "find_or_create", "upsert", "upsert!"] %}
      def self.{{ method.id }}(*args, **named_args)
        \{% raise "Please call 'unique_columns' on #{@type} before using '{{ method.id }}'" %}
      end
    {% end %}
  end
end
