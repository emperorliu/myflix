module ApplicationHelper
  def options_for_video_reviews(selected=nil)
    options_for_select([["5 Stars", 5], ["4 Stars", 4], ["3 Stars", 3], ["2 Stars", 2], ["1 Star", 1]], selected)
  end

  def render_flash_message
    flash[:success] = "To register, enter the dummy credit card number '4242424242424242', any 3-digit security code, and an expiration date in the future."
  end
end
