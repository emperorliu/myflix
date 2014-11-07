class QueueItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :video

  delegate :categories, to: :video
  delegate :title, to: :video, prefix: :video

  validates_numericality_of :position, {only_integer: true}

  def rating
    review.rating if review
  end

  def rating=(new_rating) #write setter method
    if review
      review.update_column(:rating, new_rating) #update_column bypass validations, update_attributes requires rating to not be nil, special syntax :rating for update_column
    else
      review = Review.new(user: user, video: video, rating: new_rating)
      review.save(validate: false) #bypass content validation so review can have nil content when saving review for last test
    end
  end

  private

  def review
    @review ||= Review.where(user_id: user.id, video_id: video.id).first
  end
  #video.categories is now delegated
end