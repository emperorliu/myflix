class User < ActiveRecord::Base
  validates_presence_of :email, :password, :full_name
  validates_uniqueness_of :email
  has_many :reviews
  has_many :queue_items, ->{ order(position: :asc) }

  has_secure_password validations: false

  def normalize_queue_item_positions
    queue_items.each_with_index do | queue_item, index |
      queue_item.update_attributes(position: index+1) # because index starts with 0
    end
  end

  def queued_video?(video)
    queue_items.map(&:video).include?(video) #map returns an array of videos
  end
  #moved this logic from controller to model, however the tests are operated at a high level (using sessions)so we keep the test in the controller action
end