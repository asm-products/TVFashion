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
    results = self.class.get("/#{@api_key}/series/#{show_id}/actors.xml")
      if results.blank? or results['Actors'].blank?
        return []
      else
        results["Actors"]['Actor']
      end
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
    #I may refactor this if statment to set show.banner first then check if image is uploaded and upload if false
    if Cloudinary::Utils.cloudinary_url('Shows/'+show.tvdb_id+'/Banner').blank?
      show.banner = Cloudinary::Uploader.upload('http://thetvdb.com/banners/'+show_data['banner'], :public_id => 'Shows/'+show.tvdb_id+'/Banner')['public_id'] unless show_data['banner'].blank?
    else
      show.banner = 'Shows/'+show.tvdb_id+'/Banner'
    end
    if Cloudinary::Utils.cloudinary_url('Shows/'+show.tvdb_id+'/Fanart').blank?
      show.fanart = Cloudinary::Uploader.upload('http://thetvdb.com/banners/'+show_data['fanart'], :public_id => 'Shows/'+show.tvdb_id+'/Fanart')['public_id'] unless show_data['fanart'].blank?
    else
      show.fanart = 'Shows/'+show.tvdb_id+'/Fanart'
    end
    if Cloudinary::Utils.cloudinary_url('Shows/'+show.tvdb_id+'/Poster').blank?
      show.poster = Cloudinary::Uploader.upload('http://thetvdb.com/banners/'+show_data['poster'], :public_id => 'Shows/'+show.tvdb_id+'/Poster')['public_id'] unless show_data['poster'].blank?
    else
      show.poster = 'Shows/'+show.tvdb_id+'/Poster'
    end
    show.network = show_data['Network']
    show.genre = show_data['Genre'].split('|').reject(&:empty?) unless show_data['Genre'].blank?
    show.last_updated = DateTime.strptime(api.get_datetime(),'%s')
    show.save
    return show
  end

  def add_actors(show, api, id)
    act_data = api.lookup_actors(id)
    date_now = DateTime.strptime(api.get_datetime(),'%s')
    act_data.each do |a|
      act = show.actors.new
      act.name = a['Name']
      act.tvdb_id = a['id']
      if Cloudinary::Utils.cloudinary_url('Actors/'+show.tvdb_id+'/'+act.tvdb_id).blank?
        act.image = Cloudinary::Uploader.upload('http://thetvdb.com/banners/'+a['Image'], :public_id => 'Actors/'+show.tvdb_id+'/'+act.tvdb_id)['public_id'] unless a['Image'].blank?
      else
        act.image = 'Actors/'+show.tvdb_id+'/'+act.tvdb_id
      end
      act.role = a['Role']
      act.sort_order = a['SortOrder'].to_i
      act.last_updated = date_now
      act.save
    end
  end

  def add_episodes(show, api, id)
    ep_data = api.lookup_all_episodes(id)
    date_now = DateTime.strptime(api.get_datetime(),'%s')
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
          if Cloudinary::Utils.cloudinary_url('Episodes/'+show.tvdb_id+'/'+ep.tvdb_id).blank?
            ep.image = Cloudinary::Uploader.upload('http://thetvdb.com/banners/'+e['filename'], :public_id => 'Episodes/'+show.tvdb_id+'/'+ep.tvdb_id)['public_id'] unless e['filename'].blank?
          else
            ep.image = 'Episodes/'+show.tvdb_id+'/'+ep.tvdb_id
          end
          ep.image_height = e['thumb_height']
          ep.image_width = e['thumb_width']
          ep.season_id = e['seasonid']
          ep.last_updated = date_now
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
      unless season_banners.select {|b| b['Season'] == i.to_s}.blank?
        poster = 'http://thetvdb.com/banners/'+season_banners.select {|b| b['Season'] == i.to_s}.first['BannerPath']
      else
        #put defualt here
        poster = 'http://thetvdb.com/banners/posters/108611-11.jpg'
      end
      posters << Cloudinary::Uploader.upload(poster, :public_id => 'Shows/'+show.tvdb_id+'/Season-'+i.to_s)['public_id']
    end
    show.update_attribute(:season_posters, posters)
  end
end
