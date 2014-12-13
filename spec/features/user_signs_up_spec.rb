require 'spec_helper'
# serve as integration point of all components involved, since we stubbed out the stripe wrapper and focused on sign in process in other tests

feature 'User registers', {js: true, vcr: true} do
  background do
    visit register_path
  end

  scenario "with valid user info and valid card" do
    fill_in_valid_user_info
    fill_in_valid_credit_info
    click_button "Sign Up"
    expect(page).to have_content("Thanks for your support!")
  end

  scenario "with valid user info and invalid card" do
    fill_in_valid_user_info
    fill_in_invalid_credit_info
    click_button "Sign Up"
    expect(page).to have_content("This card number looks invalid")
  end

  scenario "with valid user info and declined card" do
    fill_in_valid_user_info
    fill_in_declined_credit_info
    click_button "Sign Up"
    expect(page).to have_content("An error occurred while processing your card. Try again in a little bit.")
  end

  scenario "with invalid user info and valid card" do
    fill_in_invalid_user_info
    fill_in_valid_credit_info
    click_button "Sign Up"
    expect(page).to have_content("Invalid user information. Please check the errors below.")
  end

  scenario "with invalid user info and invalid card" do
    fill_in_invalid_user_info
    fill_in_invalid_credit_info
    click_button "Sign Up"
    expect(page).to have_content("This card number looks invalid")
  end

  # ^ how does this hit? before user validations

  scenario "with invalid user info and declined card" do
    fill_in_invalid_user_info
    fill_in_declined_credit_info
    click_button "Sign Up"
    expect(page).to have_content("Invalid user information. Please check the errors below.")
  end

  def fill_in_valid_user_info
    fill_in "Email Address", with: "joe@example.com"
    fill_in "Password", with: "12345"
    fill_in "Full Name", with: "Joe Doe"
  end

  def fill_in_valid_credit_info
    fill_in "Credit Card Number", with: "4242424242424242"
    fill_in "Security Code", with: "123"
    select "7 - July", from: "date_month"
    select "2015", from: "date_year"
  end

  def fill_in_invalid_credit_info
    fill_in "Credit Card Number", with: "123"
    fill_in "Security Code", with: "123"
    select "7 - July", from: "date_month"
    select "2015", from: "date_year"
  end

  def fill_in_declined_credit_info
    fill_in "Credit Card Number", with: "4000000000000119"
    fill_in "Security Code", with: "123"
    select "7 - July", from: "date_month"
    select "2015", from: "date_year"
  end

  def fill_in_invalid_user_info
    fill_in "Email Address", with: "joe@example.com"
    fill_in "Full Name", with: "Joe Doe"
  end
end