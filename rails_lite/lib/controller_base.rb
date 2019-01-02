require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req 
    @res = res 
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    !!@already_built_response 
  end

  # Set the response status code and header
  def redirect_to(url)
    raise error if already_built_response?
    @res.status = 302
    @res.set_header('Location', url)
    @already_built_response = @res
    self.session.store_session(@already_built_response)
    # @res.finish
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise error if already_built_response? 
    @res['Content-Type'] = content_type 
    @res.write(content)
    @already_built_response = @res
    self.session.store_session(@already_built_response)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    raise error if already_built_response?
    # self.class.name is the controller name 
    dir_path = File.dirname(__FILE__)
    # debugger
    dir_name = File.join(dir_path, "..", "views", self.class.name.underscore, 
    "#{template_name.to_s}.html.erb")

    dir_content = File.read(dir_name)

    render_content(ERB.new(dir_content).result(binding), "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end


