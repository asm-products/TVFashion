require 'thetvdb'
class ShowsController < ApplicationController
  before_action :set_show, only: [:show, :edit, :update, :destroy]
  respond_to :json

  def index
    @shows = Show.all
  end

  def show
  end

  def new
    @show = Show.new
  end

  def create
    @show = Show.new
    api = Thetvdb.new
    data = api.lookup_show(params[:show_id])
    @show.name = data['SeriesName']
    @show.overview = data['Overview']
    @show.tvdb_id = data['id']
    @show.airs_day = data['Airs_DayOfWeek']
    @show.airs_time = data['Airs_Time']
    @show.content_rating = data['ContentRating']
    @show.airs_first = data['FirstAired']
    @show.imdb_id = data['IMDB_ID']
    @show.language = data['Language']
    @show.rating = data['Rating']
    @show.rating_count = data['RatingCount']
    @show.runtime = data['Runtime']
    @show.status = data['Status']
    @show.banner = 'http://thetvdb.com/banners/'+data['banner']
    @show.fanart = 'http://thetvdb.com/banners/'+data['fanart']
    @show.poster = 'http://thetvdb.com/banners/'+data['poster']
    @show.network = data['Network']
    @show.genre = data['Genre'].split('|')
    @show.last_updated = DateTime.strptime(api.get_datetime(),'%s')
    
    @show.save
    render :show, status: :ok, location: @show, notice: 'Show was successfully created.'
  end

  def update
  end

  def destroy
    @show.destroy
    respond_to do |format|
      format.html { redirect_to shows_url, notice: 'Show was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_show
      @show = Show.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def show_params
      params.require(:show).permit(:name, :overview, :tvdb_id)
    end
end
