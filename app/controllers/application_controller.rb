class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include UsersHelper
  include PlayerPagesHelper
  

  def hello
    render html: "hi"
  end
end
