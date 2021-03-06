class SessionsController < ApplicationController
  def new
    redirect_to home_path if current_user
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      if user.active?
        session[:user_id] = user.id
        redirect_to home_path
        flash[:success] = "You are signed in, enjoy!"
      else
        flash[:danger] = "Your account has been suspended, please contact customer service."
        redirect_to sign_in_path
      end
    else
      flash[:danger] = "Invalid email or password."
      redirect_to sign_in_path
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
    flash[:danger] = "You are signed out."
  end
end