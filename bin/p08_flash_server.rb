require 'webrick'
require 'json'
require_relative '../lib/controller_base'
require_relative '../lib/router'

class Cat
  attr_reader :name, :owner

  def self.all
    @cat ||= []
  end

  def initialize(params = {})
    params ||= {}
    @name, @owner = params["name"], params["owner"]
  end

  def save
    return false unless @name.present? && @owner.present?

    Cat.all << self
    true
  end

  def inspect
    { name: name, owner: owner }.inspect
  end
end


class CatsController < ControllerBase
  def index
    @cats = Cat.all
    render :index
  end

  def new
    @cat = Cat.new
    render :new
  end

  def create
    @cat = Cat.new(params["cat"])
    if @cat.save
      flash[:errors] = "Good Job!"
      redirect_to("/cats")
    else
      flash.now[:errors] = "Try again!"
      render :new
    end
  end

  def show
    @cat = "Hello"
    render :show
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  post Regexp.new("^/cats$"), CatsController, :create
  get Regexp.new("^/cats/new$"), CatsController, :new
  get Regexp.new("^/cats/(?<cat_id>\\d+)"), CatsController, :show
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
