class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  # Checks if request method/path match route method/type
  def matches?(req)
    req.request_method.downcase.to_sym == http_method && pattern.match(req.path)
  end

  #Extract route params, instantiate controller, and run the correct action
  def run(req, res)
    route_params = {}

    match_data = self.pattern.match(req.path)
    match_data.names.each { |key| route_params[key] = match_data[key] }
    controller = controller_class.new(req, res, route_params)

    if req.request_method == "GET"
      controller.invoke_action(action_name)
    else
      cookie = req.cookies.find { |cookie| cookie.name == "_rails_lite_app" }
      authenticity_token = JSON.parse(cookie.value)["authenticity_token"]
      if authenticity_token && controller.authenticity_token == authenticity_token
       controller.invoke_action(action_name)
      else
       raise "Invalid Authenticity Token"
      end
    end
  end
end

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
