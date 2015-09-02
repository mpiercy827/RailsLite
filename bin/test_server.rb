require_relative '../lib/controller_base'
require_relative '../lib/router'

class User
  attr_reader :name, :email

  def self.all
    @user ||= []
  end

  def initialize(params = {})
    params ||= {}
    @name, @email = params["name"], params["email"]
  end

  def save
    return false unless @name.present? && @email.present?

    User.all << self
    true
  end

  def inspect
    { name: name, email: email }.inspect
  end
end


class UsersController < ControllerBase
  def index
    @users = User.all
    render :index
  end

  def new
    @user = User.new
    render :new
  end

  def create
    @user = User.new(params["user"])
    if @user.save
      flash[:errors] = "Good Job!"
      redirect_to("/users")
    else
      flash.now[:errors] = "Try again!"
      render :new
    end
  end

  def show
    @user = "Hello"
    render :show
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/users$"), UsersController, :index
  post Regexp.new("^/users$"), UsersController, :create
  get Regexp.new("^/users/new$"), UsersController, :new
  get Regexp.new("^/users/(?<user_id>\\d+)"), UsersController, :show
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
