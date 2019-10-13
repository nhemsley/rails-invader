require 'active_support'
require 'active_support/core_ext/object'

require "active_record"
require 'pry'

require_relative 'lib/railsinvader/railsinvader'
require_relative 'models/user'

class RailsInvader < Thor
  desc "tables", "Interrogate database tables"
  method_option :ignore_tables, type: :string, default: []
  def tables
    init
    tables = interrogator.tables.reject{|table| options[:ignore_tables].include? table}
    tables.each do |table|
      puts table
    end
  end

  desc "tables_columns", "Interrogate database tables and columns"
  method_option :ignore_tables, type: :string, default: []
  def tables_columns
    init
    tables = interrogator.tables.reject{|table| options[:ignore_tables].include? table}
    errors = []
    tables.each do |table|
      begin
        puts table
        interrogator.columns(table).each do |column|
          puts "\t#{column.name}: #{column.type}"
        end
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

  desc "pry", "Open pry session"
  def pry
    init
    binding.pry
    puts "pry"
  end

  private

    def interrogator
      interrogator = ::RailsInvader::Database::Interrogator.new
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