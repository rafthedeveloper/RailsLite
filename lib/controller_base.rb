require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative 'session'
require_relative 'params'


class ControllerBase
  attr_reader :req, :res, :params
  attr_accessor :already_built_response

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response == true
  end

  # Set the response status code and header
  def redirect_to(url)
    raise Exception if already_built_response?
    self.res.header["location"] = url
    self.res.status = 302
    @already_built_response = true
    session.store_session(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise Exception if already_built_response?
    self.res.body = content
    self.res.content_type = content_type
    @already_built_response = true
    session.store_session(@res)
  end

  def render(template_name)
    controller_name = self.class.name.underscore
    file = File.open("views/#{controller_name}/#{template_name}.html.erb")
    content = ""

    file.each { |line| content << line }
    e = ERB.new(content).result(binding)
    render_content(e, "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  def invoke_action(name)
    self.send("#{name}")

  end
end
