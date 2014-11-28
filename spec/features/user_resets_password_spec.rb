require 'spec_helper'

feature 'User resets password' do
  scenario 'user successfully resets the password' do
    jeff = Fabricate(:user, password: "oldpw")
    visit sign_in_path
    click_link "Forgot Password"
    fill_in "Email Address", with: jeff.email
    click_button "Send Email"

    open_email(jeff.email)
    current_email.click_link("Reset My Password")

    fill_in "New Password", with: "newpw"
    click_button "Reset Password"

    fill_in "Email Address", with: jeff.email
    fill_in "Password", with: "newpw"
    click_button "Sign in"

    expect(page).to have_content("Welcome, #{jeff.full_name}")

    clear_email
  end
end