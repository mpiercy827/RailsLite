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
    define_method(http_method) do |path, controller_class, action_name|
      pattern = make_pattern(path)
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  #Makes a Regex for a url pattern
  def make_pattern(string)
    string = string[1..-1] if string[0] == "/"
    regex_array = []
    string.split("/").each do |fragment|
      if fragment[0] == ":"
        var = fragment[1..-1]
        regex_array << "(?<#{var}>\\d+)"
      else
        regex_array << fragment
      end
    end

    Regexp.new("^/#{regex_array.join("/")}$")
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
