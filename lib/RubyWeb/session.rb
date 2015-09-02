require 'json'
require 'webrick'

class Session
  #Find existing cookie for this app in request or create a new one.
  def initialize(req)
    req.cookies.each do |cookie|
      @cookie = JSON.parse(cookie.value) if cookie.name == "_rails_lite_app"
    end

    @cookie ||= {}
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  #Serialize cookie to json and add it to response
  def store_session(res)
    cookie = WEBrick::Cookie.new("_rails_lite_app", @cookie.to_json)
    cookie.path = "/"
    res.cookies << cookie
  end
end
