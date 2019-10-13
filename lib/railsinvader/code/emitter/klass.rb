require 'erb'

module RailsInvader::Code::Emitter
  class Klass
    def initialize(name, base_class: ActiveRecord::Base)
      @name = name
      @base_klass = base_class.to_s
    end

    def emit(template = nil)
      if template.nil?
        template_path = Pathname.new(File.dirname(__FILE__)).join('templates')
        template = IO.read(template_path.join('klass.rb.erb'))
      end
      output = ERB.new(template).result(binding)
    end
  end
end