require 'spec_helper'

feature "user signs in" do
  scenario "with valid email and password" do
    jeff = Fabricate(:user)
    sign_in(jeff)
    expect(page).to have_content jeff.full_name
  end

  scenario "with deactivated user" do
    jeff = Fabricate(:user, active: false)
    sign_in(jeff)
    expect(page).not_to have_content jeff.full_name
    expect(page).to have_content("Your account has been suspended, please contact customer service.")
  end
end
