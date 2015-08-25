require_relative '../phase2/controller_base'
require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require 'byebug'

module Phase3
  class ControllerBase < Phase2::ControllerBase
    # use ERB and binding to evaluate templates
    # pass the rendered html to render_content
    def render(template_name)
      file = File.read(
        "views/#{self.class.to_s.underscore}/#{template_name}.html.erb")
      content = ERB.new(file).result(binding)
      render_content(content,"text/html")
    end
  end
end
