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
    param_id=params[:show_id]
    api.add_show(@show, api, param_id)

    t = Thread.new do
      api.add_actors(@show, api, param_id)
      api.add_episodes(@show, api, param_id)
      api.add_season_posters(@show, api, param_id)
      ActiveRecord::Base.connection.close
    end
    at_exit { t.join }
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
