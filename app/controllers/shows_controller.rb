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
    #Add check if show in db already, if so re-route to show mage and say show already here

    @show = Show.new
    api = Thetvdb.new
    show_data = api.lookup_show(params[:show_id])
    current_date = DateTime.strptime(api.get_datetime(),'%s')
    @show.name = show_data['SeriesName']
    @show.overview = show_data['Overview']
    @show.tvdb_id = show_data['id']
    @show.airs_day = show_data['Airs_DayOfWeek']
    @show.airs_time = show_data['Airs_Time']
    @show.content_rating = show_data['ContentRating']
    @show.airs_first = show_data['FirstAired']
    @show.imdb_id = show_data['IMDB_ID']
    @show.language = show_data['Language']
    @show.rating = show_data['Rating'].to_f
    @show.rating_count = show_data['RatingCount'].to_i
    @show.runtime = show_data['Runtime'].to_i
    @show.status = show_data['Status']
    if show_data['banner'].nil?
      @show.banner = nil
    else
      @show.banner = 'http://thetvdb.com/banners/'+show_data['banner']
    end
    if show_data['fanart'].nil?
      @show.fanart = nil
    else
      @show.fanart = 'http://thetvdb.com/banners/'+show_data['fanart']
    end
    if show_data['poster'].nil?
      @show.poster = nil
    else
      @show.poster = 'http://thetvdb.com/banners/'+show_data['poster']
    end
    @show.network = show_data['Network']
    if show_data['Genre'].nil?
      @show.genre = nil
    else
      @show.genre = show_data['Genre'].split('|').reject(&:empty?)
    end
    @show.last_updated = current_date
    @show.save
    #route to to new show and do the rest in the background

    act_data = api.lookup_actors(params[:show_id])
    act_data.each do |a|
      act = @show.actors.new
      act.name = a['Name']
      act.tvdb_id = a['id']
      if a['Image'].nil?
        act.image = nil
      else
        act.image = 'http://thetvdb.com/banners/'+a['Image']
      end
      act.role = a['Role']
      act.sort_order = a['SortOrder'].to_i
      act.last_updated = current_date
      act.save
    end

    ep_data = api.lookup_all_episodes(params[:show_id])
    ep_data.each do |e|
      unless e['FirstAired'].nil?
        if Date.parse(e['FirstAired']) < Date.today
          puts e['FirstAired']
          ep = @show.episodes.new
          ep.tvdb_id = e['id']
          ep.episode_number = e['EpisodeNumber']
          ep.season_number = e['SeasonNumber']
          ep.name = e['EpisodeName']
          ep.aired = Date.parse(e['FirstAired'])
          ep.imdb_id = e['IMDB_ID']
          ep.language = e['Language']
          ep.overview = e['Overview']
          ep.rating = e['Rating'].to_f
          ep.rating_count = e['RatingCount'].to_i
          if e['filename'].nil?
            ep.image = nil
          else
            ep.image = 'http://thetvdb.com/banners/'+e['filename']
          end
          ep.image_height = e['thumb_height']
          ep.image_width = e['thumb_width']
          ep.season_id = e['seasonid']
          ep.last_updated = current_date
          if e['Director'].nil?
            ep.directors = nil
          else
            ep.directors = e['Director'].split('|').reject(&:empty?)
          end
          if e['GuestStars'].nil?
            ep.guest_stars = nil
          else
            ep.guest_stars = e['GuestStars'].split('|').reject(&:empty?)
          end
          if e['Writer'].nil?
            ep.writers = nil
          else
            ep.writers = e['Writer'].split('|').reject(&:empty?)
          end

          ep.save
        end
      end
    end


    #Add season poster lookup loop

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
