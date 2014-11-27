require 'spec_helper'

feature "user invites friend" do
  scenario "user invites a friend and the invitation is accepted" do
    jeff = Fabricate(:user)
    sign_in(jeff)

    invite_a_friend
    friend_accepts_invitation
    friend_signs_in

    friend_should_follow(jeff)
    inviter_should_follow_friend(jeff)

    clear_email
  end

  def invite_a_friend
    visit new_invitation_path
    fill_in "Friend's Name", with: "Sean"
    fill_in "Friend's Email Address", with: "sean@gmail.com"
    fill_in "Invitation Message", with: "Yo sign up."
    click_button "Send Invitation"
    sign_out
  end

  def friend_accepts_invitation
    open_email "sean@gmail.com"
    current_email.click_link("Accept this invitation")

    fill_in "Password", with: "password"
    fill_in "Full Name", with: "Sean"
    click_button "Sign Up"
  end

  def friend_signs_in
    fill_in "Email Address", with: "sean@gmail.com"
    fill_in "Confirm Password", with: "password"
    click_button "Sign in"
  end

  def friend_should_follow(user)
    click_link "People"
    expect(page).to have_content(user.full_name)
    sign_out
  end

  def inviter_should_follow_friend(inviter)
    sign_in(inviter)
    click_link "People"
    expect(page).to have_content("Sean")
  end
end