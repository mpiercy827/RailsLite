class Flash
  attr_reader :now

  def initialize(req)
    @now = {}
    @later = {}
    req.cookies.each do |cookie|
      @now = JSON.parse(cookie.value) if cookie.name == "_rails_lite_app_flash"
    end
  end

  def [](key)
    now[key.to_sym] || now[key.to_s] || @later[key.to_sym] || @later[key.to_s]
  end

  def []=(key, value)
    @later[key] = value
  end

  def store_flash(res)
    res.cookies << WEBrick::Cookie.new("_rails_lite_app_flash", @later.to_json)
  end
end
