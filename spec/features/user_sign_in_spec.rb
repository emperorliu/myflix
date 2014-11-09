require 'spec_helper'

feature "user signs in" do
  scenario "with valid email and password" do
    jeff = Fabricate(:user)
    sign_in(jeff)
    expect(page).to have_content jeff.full_name
  end
end
