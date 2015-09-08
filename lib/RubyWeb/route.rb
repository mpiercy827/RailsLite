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
      cookie = req.cookies.find { |c| c.name == "_rails_lite_app" }
      auth_token = JSON.parse(cookie.value)["authenticity_token"]
      if auth_token && controller.session["authenticity_token"] == auth_token
        controller.invoke_action(action_name)
      else
        raise "Invalid Authenticity Token"
      end
    end
  end
end
