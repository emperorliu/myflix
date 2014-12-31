require 'spec_helper'

feature "Admin sees payments" do
  background do
    jeff = Fabricate(:user, full_name: "Jeff Liu", email: "jeff@gmail.com")
    Fabricate(:payment, amount: 999, user: jeff)
  end
  scenario "admin can see payments" do
    sign_in(Fabricate(:admin))
    visit admin_payments_path
    expect(page).to have_content("$9.99")
    expect(page).to have_content("Jeff Liu")
    expect(page).to have_content("jeff@gmail.com")
  end


  scenario "user cannot see payments" do
    sign_in(Fabricate(:user))
    visit admin_payments_path
    expect(page).not_to have_content("$9.99")
    expect(page).not_to have_content("Jeff Liu")
    expect(page).to have_content("You are not authorized to do that.")
  end
end