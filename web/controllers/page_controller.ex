defmodule Ocjb.PageController do
  use Ocjb.Web, :controller

  def index(conn, _params) do
    tracks = prep_track_data
    render conn, "index.html", tracks: tracks
  end

  def tags(conn, params) do
    filename = params["filename"]
    file = File.read! "web/static/assets/mp3/#{filename}"
    frames = ID3v2.frames file
    render conn, "tags.html", frames: frames
  end

  def prep_track_data do
    GenServer.call IndexerWorker, :tracklist
  end

end
