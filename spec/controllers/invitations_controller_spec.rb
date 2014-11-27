require 'spec_helper'

describe InvitationsController do
  describe "GET new" do
    it "sets @invitation to a new invitation" do
      set_current_user
      get :new
      expect(assigns(:invitation)).to be_new_record
      expect(assigns(:invitation)).to be_instance_of Invitation
    end

    it_behaves_like "requires sign in" do
      let(:action) { get :new }
    end
  end

  describe "POST create" do
    it_behaves_like "requires sign in" do
      let(:action) { post :create }
    end

    context "with valid inputs" do
      before { ActionMailer::Base.deliveries.clear }

      it "creates an invitation" do
        set_current_user
        post :create, invitation: { recipient_name: "jeff", recipient_email: "jeff@gmail.com", message: "Yo join Myflix" }
        expect(Invitation.count).to eq(1)
      end

      it "sends an email to the recipient" do
        set_current_user
        post :create, invitation: { recipient_name: "jeff", recipient_email: "jeff@gmail.com", message: "Yo join Myflix" }
        expect(ActionMailer::Base.deliveries.last.to).to eq(['jeff@gmail.com'])
      end

      it "redirects back to the invitation page" do
        set_current_user
        post :create, invitation: { recipient_name: "jeff", recipient_email: "jeff@gmail.com", message: "Yo join Myflix" }
        expect(response).to redirect_to new_invitation_path
      end

      it "sets the flash success message" do
        set_current_user
        post :create, invitation: { recipient_name: "jeff", recipient_email: "jeff@gmail.com", message: "Yo join Myflix" }
        expect(flash[:success]).to be_present
      end
    end

    context "with invalid inputs" do
      before { ActionMailer::Base.deliveries.clear }

      it "renders the new template" do
        set_current_user
        post :create, invitation: { recipient_email: "jeff@gmail.com", message: "Yo join Myflix" }
        expect(response).to render_template :new
      end

      it "does not create an invitation" do
        set_current_user
        post :create, invitation: { recipient_email: "jeff@gmail.com", message: "Yo join Myflix" }
        expect(Invitation.count).to eq(0)
      end

      it "does not send an email" do
        set_current_user
        post :create, invitation: { recipient_email: "jeff@gmail.com", message: "Yo join Myflix" }
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it "sets flash error message" do
        set_current_user
        post :create, invitation: { recipient_email: "jeff@gmail.com", message: "Yo join Myflix" }
        expect(flash[:danger]).to be_present
      end

      it "sets the @invitation instance variable" do
        # for this you just change invitation to @invitation
        set_current_user
        post :create, invitation: { recipient_email: "jeff@gmail.com", message: "Yo join Myflix" }
        expect(assigns(:invitation)).to be_present
      end
    end
  end
end