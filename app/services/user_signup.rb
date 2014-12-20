class UserSignup

  attr_reader :error_messages

  def initialize(user)
    @user = user
  end

  def sign_up(stripe_token, invitation_token)
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    if @user.valid?
      payment = StripeWrapper::Charge.create(
        :amount => 999,
        :card => stripe_token,
        :description => "Sign up charge for #{@user.email}"
      )
      if payment.successful?
        @user.save
        # valid personal info & declined card won't come here
        handle_invitation(invitation_token)
        AppMailer.send_welcome_email(@user).deliver
        @status = :success
        self
      else
        @status = :failed
        @error_messages = payment.error_message
        self
      end
    else
      @status = :failed
      @error_messages = "Invalid user information. Please check the errors below."
      self
    end
  end

  def successful?
    @status == :success
  end

  private

  def handle_invitation(invitation_token)
    if invitation_token.present?
      invitation = Invitation.find_by(token: invitation_token)
      @user.follow(invitation.inviter)
      invitation.inviter.follow(@user)
      invitation.update_column(:token, nil)
    end
  end

end