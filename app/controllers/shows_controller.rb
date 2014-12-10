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
    @show.tvdb_id = data['id']
    @show.name = data['SeriesName']
    @show.overview = data['Overview']
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
