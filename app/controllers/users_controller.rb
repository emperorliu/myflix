class UsersController < ApplicationController
  before_action :require_user, only: [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.valid?
      # Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
      # begin
      #   charge = Stripe::Charge.create(
      #     :amount => 999,
      #     :currency => "usd",
      #     :card => params[:stripeToken],
      #     :description => "Sign up charge for #{@user.email}"
      #   )
      # rescue Stripe::CardError => e
      #   flash[:danger] = e.message
      # end
      charge1 = StripeWrapper::Charge.create(
        :amount => 999,
        :card => params[:stripeToken],
        :description => "Sign up charge for #{@user.email}"
      )
      if charge1.successful?
        @user.save
        # valid personal info & declined card won't come here
        handle_invitation
        flash[:success] = "Thanks for your support!"
        AppMailer.send_welcome_email(@user).deliver
        redirect_to sign_in_path
      else
        flash[:danger] = charge1.error_message
        render :new
      end
    else
      flash[:danger] = "Invalid user information. Please check the errors below."
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new_with_invitation_token
    invitation = Invitation.where(token: params[:token]).first
    if invitation
      @user = User.new(email: invitation.recipient_email)
      @invitation_token = invitation.token
      render :new
    else
      redirect_to expired_token_path
    end
  end

  private

  def user_params
    params.require(:user).permit!
  end

  def handle_invitation
    if params[:invitation_token].present?
      invitation = Invitation.where(token: params[:invitation_token]).first
      @user.follow(invitation.inviter)
      invitation.inviter.follow(@user)
      invitation.update_column(:token, nil)
    end
  end
end