require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params
  attr_accessor :already_built_response

  # Setup the controller
  def initialize(req, res, route_params = {})
    @params = route_params.merge(req.params)
    @already_built_response = false
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Double render" if @already_built_response
    @already_built_response = true
    @res['Location'] = url
    @res.status = 302
    session.store_session(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Double render" if @already_built_response
    @already_built_response = true
    @res['Content-Type'] = content_type
    @res.write(content)
    session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    full_path = "views/#{self.class.to_s.underscore}/#{template_name}.html.erb"
    file = File.read(full_path)
    template = ERB.new(file).result(binding)
    render_content(template, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
  end
end
