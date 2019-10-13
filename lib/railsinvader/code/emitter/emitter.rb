module RailsInvader::Code::Emitter
  class Emitter
    def initialize(interrogator)
      @interrogator = interrogator
    end

    def klasses
      @interrogator.tables.map do |table| 
        klass_name = table.singularize.camelize
        klass = Klass.new(klass_name)
      end
    end
  end
end