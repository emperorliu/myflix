class Admin::VideosController < AdminsController

  def new
    @video = Video.new
  end

  def create
    @video = Video.new(video_params)
    if @video.save
      redirect_to new_admin_video_path
      flash[:success] = "You created a video for '#{@video.title}' successfully."
    else
      flash[:danger] = "The video wasn't created."
      render :new
    end
  end

  private

  def video_params
    params.require(:video).permit!
  end
end