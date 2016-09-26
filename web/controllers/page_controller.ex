defmodule Ocjb.PageController do
  use Ocjb.Web, :controller

  def init do
    IO.puts 'it works'
  end

  def index(conn, _params) do
    tracks = prep_track_data
    render conn, "index.html", tracks: tracks
  end

  def tags(conn, params) do
    filename = params["filename"]
    file = File.read! "#{filename}.mp3"
    frames = ID3v2.frames file
    IO.puts "wat, #{inspect frames}"
    render conn, "tags.html", frames: frames
  end

  def prep_track_data do
    GenServer.call IndexerWorker, :tracklist
  end

end
