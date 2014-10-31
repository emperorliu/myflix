class ReviewsController < ApplicationController
  before_action :require_user
  
  def create
    @video = Video.find(params[:video_id])
    review = @video.reviews.build(review_params.merge!(user: current_user))
    # if you're creating an object through association, build should be preferred over new
    if review.save
      redirect_to video_path(@video)
    else
      @reviews = @video.reviews.reload
      render 'videos/show'
    end
  end

  private

  def review_params
    params.require(:review).permit!
  end
end