class Flash
  attr_reader :now

  def initialize(req)
    @now = {}
    @later = {}
    req.cookies.each do |cookie|
      if cookie.name == "_rails_lite_app_flash"
        @now = JSON.parse(cookie.value)
      end
    end
  end

  def [](key)
    now[key.to_sym] ||
    now[key.to_s] ||
    @later[key.to_sym] ||
    @later[key.to_s]
  end

  def []=(key, value)
    @later[key] = value
  end

  def store_flash(res)
    cookie = WEBrick::Cookie.new("_rails_lite_app_flash", @later.to_json)
    res.cookies << cookie
  end
end
