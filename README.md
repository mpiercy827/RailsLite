# RubyWeb

## Description
RubyWeb is an MVC web development framework inspired by Ruby on Rails. RubyWeb provides a
light-weight WEBrick server along with ControllerBase and Router classes, complete with
cookies and params functionality. See below for how to use RubyWeb in your project!

## Features & Usage
* Offers Router class which draws route for the user's app.
* Each route creates an instance of the ControllerBase course, which handles rendering and redirecting logic.
* Users can store cookies in the session hash, which can be used for creating user authentication systems.
* Gives users a flash to store and render messages for their app's users.
* Prevents CSRF attacks on the user's app with the use of randomly generated authenticity tokens.

## Future Goals
* [ ] Implement an object relational mapping and give users a SQLite database for models.
* [ ] Add url helpers, so users can refer to routes more generally.
* [ ] Allow RubyWeb to handle put and delete requests.
