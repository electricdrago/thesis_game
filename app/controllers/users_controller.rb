class UsersController < ApplicationController

  def signin
    params = account_params
    @num = 1
    @message = ""
    if @user = User.find_by(name: params[:name].downcase)
      if @user.authenticate(params[:password])
        @message = "user already existed and had the correct password"
        log_in @user
        @num = 2
      else
        @message = "user already existed and password is wrong"
      end
    else
      @user = User.new(name: params[:name], password: params[:password], password_confirmation: params[:password])
      if @user.save
        @message = "user didnt exist and was created"
        log_in @user
        @num = 2
      else
        @message = "user didnt existed and couldnt be created"
      end

    end
    render json: {message: @message, num: @num}
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
