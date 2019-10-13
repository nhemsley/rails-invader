module RailsInvader
  module Database
    class Interrogator

      attr_accessor :errors
      def initialize(ignore_tables: [])
        @ignore_tables = ignore_tables
        @errors = {}
      end

      def tables
        ActiveRecord::Base.connection.tables.reject{|table| @ignore_tables.include? table}
      end

      def columns(table)
        table_klass = klass table
        table_klass.columns
      end

      def column_names(table)
        columns(table).map(&:name)
      end

      def klass(table)
        klass_name = table.singularize.camelize
        the_klass = Class.new(ActiveRecord::Base) do

        end
        Models.const_set(klass_name, the_klass)
      end
      
    end
  end

  module Models
  end
end