require 'thetvdb'

class ShowSearchesController  < ApplicationController
  respond_to :json

  def new
    api = Thetvdb.new
    @shows = api.search_show(params[:query])
    render json: @shows
  end
end
