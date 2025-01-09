class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i[create destroy]

  def create
    @micropost = current_user.microposts.new(micropost_params)
    if @micropost.save
      flash[:success] = 'Micropost created!'
      redirect_to root_path
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home'
    end
  end

  def destroy
    # TODO
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content)
  end
end
