require 'thetvdb'

class ShowSearchesController  < ApplicationController
  respond_to :json

  def create
    api = Thetvdb.new
    @shows = api.search_show(params[:query])
    render json: @shows
  end
end
