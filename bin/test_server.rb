require_relative '../lib/RubyWeb/controller_base'
require_relative '../lib/RubyWeb/router'
require_relative '../lib/SQLObject/sqlobject'

class User < SQLObject
  attr_reader :id, :name, :email

  def initialize(params = {})
    params ||= {}
    @name, @email = params["name"], params["email"]
  end


  def inspect
    "Name: #{name}, Email: #{email}"
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
    @user = User.find(params[:user_id].to_i)
    render :show
  end
end

router = Router.new
router.draw do
  get "users", UsersController, :index
  post "users", UsersController, :create
  get "users/new", UsersController, :new
  get "users/:user_id", UsersController, :show
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
