require 'httparty'
class Thetvdb
  include HTTParty
  base_uri 'http://thetvdb.com/api'

  def initialize
    @api_key = ENV['TVFASHION_TVDB_API']
  end

  def search_show(show_name)
    results = self.class.get("/GetSeries.php", {:query => {:seriesname => show_name, :language => 'en'}})
      if results.nil?
        return []
      else
        results = results["Data"]["Series"]
          if results.kind_of?(Array)
            return results
          else
            return [results]
          end
      end
  end

  def lookup_show(show_id)
    self.class.get("/#{@api_key}/series/#{show_id}/en.xml")["Data"]["Series"]
  end

  def lookup_episode(episode_id)
    self.class.get("/#{@api_key}/episodes/#{episode_id}/en.xml")["Data"]["Episode"]
  end

  def lookup_all_episodes(show_id)
    self.class.get("/#{@api_key}/series/#{show_id}/all/en.xml")["Data"]["Episode"]
  end

  def lookup_actors(show_id)
    self.class.get("/#{@api_key}/series/#{show_id}/actors.xml")["Actors"]["Actor"]
  end

  def lookup_banners(show_id)
    self.class.get("/#{@api_key}/series/#{show_id}/banners.xml")["Banners"]["Banner"]
  end

  def lookup_episode_date(series_id, date)
    self.class.get("/GetEpisodeByAirDate.php?apikey=#{@api_key}&seriesid=#{series_id}&airdate=#{date}")["Data"]["Episode"]
  end

  def get_datetime()
    self.class.get("/Updates.php?type=none")['Items']['Time']
  end

  def add_show(show, api, id)
    show_data = api.lookup_show(id)
    show.name = show_data['SeriesName']
    show.overview = show_data['Overview']
    show.tvdb_id = show_data['id']
    show.airs_day = show_data['Airs_DayOfWeek']
    show.airs_time = show_data['Airs_Time']
    show.content_rating = show_data['ContentRating']
    show.airs_first = show_data['FirstAired']
    show.imdb_id = show_data['IMDB_ID']
    show.language = show_data['Language']
    show.rating = show_data['Rating'].to_f
    show.rating_count = show_data['RatingCount'].to_i
    show.runtime = show_data['Runtime'].to_i
    show.status = show_data['Status']
    show.banner = 'http://thetvdb.com/banners/'+show_data['banner'] unless show_data['banner'].blank?
    show.fanart = 'http://thetvdb.com/banners/'+show_data['fanart'] unless show_data['fanart'].blank?
    show.poster = 'http://thetvdb.com/banners/'+show_data['poster'] unless show_data['poster'].blank?
    show.network = show_data['Network']
    show.genre = show_data['Genre'].split('|').reject(&:empty?) unless show_data['Genre'].blank?
    show.last_updated = DateTime.strptime(api.get_datetime(),'%s')
    show.save
    return show
  end

  def add_actors(show, api, id)
    act_data = api.lookup_actors(id)
    act_data.each do |a|
      act = show.actors.new
      act.name = a['Name']
      act.tvdb_id = a['id']
      act.image = 'http://thetvdb.com/banners/'+a['Image'] unless a['Image'].blank?
      act.role = a['Role']
      act.sort_order = a['SortOrder'].to_i
      act.last_updated = DateTime.strptime(api.get_datetime(),'%s')
      act.save
    end
  end

  def add_episodes(show, api, id)
    ep_data = api.lookup_all_episodes(id)
    ep_data.each do |e|
      unless e['FirstAired'].nil?
        if Date.parse(e['FirstAired']) < Date.today
          ep = show.episodes.new
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
          ep.last_updated = DateTime.strptime(api.get_datetime(),'%s')
          ep.directors = e['Director'].split('|').reject(&:empty?) unless e['Director'].blank?
          ep.guest_stars = e['GuestStars'].split('|').reject(&:empty?) unless e['GuestStars'].blank?
          ep.writers = e['Writer'].split('|').reject(&:empty?) unless e['Writer'].blank?
          ep.save
        end
      end
    end
  end

  def add_season_posters(show, api, id)
    season_count = show.episodes.maximum('season_number')
    banners = api.lookup_banners(id)
    season_banners = banners.select {|b| b['BannerType2'] == 'season'}
    posters=[]
    for i in 0..season_count
      posters << 'http://thetvdb.com/banners/'+season_banners.select {|b| b['Season'] == i.to_s}.first['BannerPath']
    end
    show.update_attribute(:season_posters, posters)
  end
end
