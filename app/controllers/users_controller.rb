class UsersController < ApplicationController

  def signin
    params = account_params
    @num = 1
    @message = ""
    if @user = User.find_by(name: params[:name].downcase)
      if @user.authenticate(params[:password])
        @message = "User already existed and had the correct password"
        log_in @user
        redirect_to '/story'
      else
        @message = "User already existed and password is wrong"
        render 'main_pages/home'
      end
    else
      @user = User.new(name: params[:name], password: params[:password], password_confirmation: params[:password])
      if @user.save
        @message = "User didn't exist and was created"
        log_in @user
        redirect_to '/story'
      else
        @message = "User did not exist but could not be created"
        render 'main_pages/home'
      end

    end

  end

  def destroy
    log_out
    redirect_to root_url
  end

  private
    def account_params

      params.permit(:name, :password)
    end

end
