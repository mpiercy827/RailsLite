require_relative "route"

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    instance_eval(&proc)
  end

  #Defines methods for get, post, put and delete requests
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  #Returns matching route or nil
  def match(req)
    routes.find { |route| route.matches?(req) }
  end

  #Run a matching route or return a 404 if it doesn't exist
  def run(req, res)
    route = match(req)
    route.nil? ? res.status = 404 : route.run(req, res)
  end
end
