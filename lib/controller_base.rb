require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative "session"
require_relative "params"
require_relative "flash"

class ControllerBase
  attr_reader :req, :res
  attr_reader :params

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
  end

  #Used to display Messages to app users
  def flash
    @flash ||= Flash.new(@req)
  end

  #Used for storing cookies
  def session
    @session ||= Session.new(@req)
  end


  def redirect_to(url)
    check_for_existing_response
    self.res.status = 302
    self.res["location"] = url
    store_flash_and_session
  end

  def render_content(content, content_type)
    check_for_existing_response
    self.res.body = content
    self.res.content_type = content_type
    store_flash_and_session
  end

  def render(template_name)
    controller_name = self.class.to_s.underscore
    template = File.read("views/#{controller_name}/#{template_name}.html.erb")
    content = ERB.new(template).result(binding)

    render_content(content, 'text/html')
  end

  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
  end

  def authenticity_token
    session[:authenticity_token] = SecureRandom.urlsafe_base64
  end

  private
  def already_built_response?
    @already_built_response
  end

  def check_for_existing_response
    raise "Response has already been made" if already_built_response?
    @already_built_response = true
  end

  def store_flash_and_session
    session.store_session(@res)
    flash.store_flash(@res)
  end
end
