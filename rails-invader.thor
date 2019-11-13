require 'active_support'
require 'active_support/core_ext/object'

require "active_record"
require 'pry'

require_relative 'lib/railsinvader/railsinvader'
require_relative 'models/user'

class RailsInvader < Thor
  desc "tables", "Display database tables"
  method_option :ignore_tables, type: :string, default: []
  def tables
    init
    get_tables.each do |table|
      puts table
    end
  end

  desc "tables_columns", "Display database tables and columns"
  method_option :ignore_tables, type: :string, default: []
  def tables_columns
    init
    
    errors = []
    get_tables.each do |table|
      begin
        output = []
        output << table
        interrogator.columns(table).each do |column|
          output << "\t#{column.name}: #{column.type}"
        end
        puts output.join("\n")
      rescue ActiveRecord::StatementInvalid => e
        errors << {table: table, exception: e}
      end
    end

    unless errors.empty?
      puts "Errors exist with tables:"
      errors.each do |error|
        puts error[:table]
        puts "\t #{error[:exception]}"
      end
    end
  end

  desc "code", "Display rails activerecord code to load database"
  method_option :ignore_tables, type: :string, default: []
  method_option :inheritance_column, type: :string, default: nil
  method_option :base_class, type: :string
  def code
    init
    get_code(options)[:output].each do |klass|
      puts klass
    end
  end

  desc "pry", "Open pry session"
  method_option :ignore_tables, type: :string, default: []
  method_option :inheritance_column, type: :string, default: nil
  def pry
    init

    get_code(options)[:output].each do |klass|
      eval klass
    end

    binding.pry
    puts "Exiting"
  end

  private

    def get_code(options)
      errors = []
      output = []
      emitter = ::RailsInvader::Code::Emitter::Emitter.new(interrogator, options)
      emitter.klasses.each do |klass|
        begin
          output << klass.emit
        rescue ActiveRecord::StatementInvalid => e
          errors << {klass: klass, exception: e}
        end
      end

      {output: output, errors: errors}
    end

    def get_tables
      tables = interrogator.tables
    end

    def interrogator
      interrogator = ::RailsInvader::Database::Interrogator.new(ignore_tables: @options[:ignore_tables])
    end

    def establish_db_connection
      ActiveRecord::Base.establish_connection(db_config)
    end

    def db_config
      YAML::load(File.open('database.yml'))
    end

    def init
      establish_db_connection
    end
end