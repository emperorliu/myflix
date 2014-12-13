class VideosController < ApplicationController

  before_action :set_video, only: [:show, :watch]
  before_action :require_user

  def index
    @videos = Video.all
    @categories = Category.all
  end

  def show
    @reviews = @video.reviews
  end

  def search
    @results = Video.search_by_title(params[:search_term])
  end

  def watch
  end

  private

  def set_video
    @video = Video.find(params[:id]).decorate
  end

end