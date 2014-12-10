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
end
