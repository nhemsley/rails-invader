module RailsInvader::Code::Emitter
  class Emitter
    def initialize(interrogator, options = {})
      @interrogator = interrogator
      @options = options
    end

    def klasses
      @interrogator.tables.map do |table| 
        klass_name = table.singularize.camelize
        klass = Klass.new(klass_name, ** @options.symbolize_keys.slice(:base_class, :inheritance_column))
      end
    end
  end
end