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
    @show.banner = 'http://thetvdb.com/banners/'+show_data['banner'] unless show_data['banner'].blank?
    @show.fanart = 'http://thetvdb.com/banners/'+show_data['fanart'] unless show_data['fanart'].blank?
    @show.poster = 'http://thetvdb.com/banners/'+show_data['poster'] unless show_data['poster'].blank?
    @show.network = show_data['Network']
    @show.genre = show_data['Genre'].split('|').reject(&:empty?) unless show_data['Genre'].blank?
    @show.last_updated = current_date
    @show.save
    #route to to new show and do the rest in the background

    act_data = api.lookup_actors(params[:show_id])
    act_data.each do |a|
      act = @show.actors.new
      act.name = a['Name']
      act.tvdb_id = a['id']
      act.image = 'http://thetvdb.com/banners/'+a['Image'] unless a['Image'].blank?
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
          ep.image = 'http://thetvdb.com/banners/'+e['filename'] unless e['filename'].blank?
          ep.image_height = e['thumb_height']
          ep.image_width = e['thumb_width']
          ep.season_id = e['seasonid']
          ep.last_updated = current_date
          ep.directors = e['Director'].split('|').reject(&:empty?) unless e['Director'].blank?
          ep.guest_stars = e['GuestStars'].split('|').reject(&:empty?) unless e['GuestStars'].blank?
          ep.writers = e['Writer'].split('|').reject(&:empty?) unless e['Writer'].blank?

          ep.save
        end
      end
    end

    season_count = @show.episodes.maximum('season_number')
    banners = api.lookup_banners(params[:show_id])
    season_banners = banners.select {|b| b['BannerType2'] == 'season'}
    posters=[]
    for i in 0..season_count
      posters << 'http://thetvdb.com/banners/'+season_banners.select {|b| b['Season'] == i.to_s}.first['BannerPath']
    end
    @show.update_attribute(:season_posters, posters)

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
