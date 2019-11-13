require 'erb'

module RailsInvader::Code::Emitter
  class Klass
    def initialize(name, base_class: ActiveRecord::Base, inheritance_column: nil)
      @name = name
      @base_klass = base_class.to_s
      @inheritance_column = inheritance_column
    end

    def emit(template = nil)
      if template.nil?
        template_path = Pathname.new(File.dirname(__FILE__)).join('templates')
        template = IO.read(template_path.join('klass.rb.erb'))
      end
      output = ERB.new(template).result(binding)
    end

    def inheritance_column_for_template
      return "self.inheritance_column = :#{@inheritance_column}" if @inheritance_column
      ""
    end
  end
end