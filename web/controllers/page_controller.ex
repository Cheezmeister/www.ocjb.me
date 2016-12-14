defmodule Ocjb.PageController do
  use Ocjb.Web, :controller

  def index(conn, _params) do
		prep_track = fn(track) ->
      Map.merge track, %{
        devUrl: "/mp3" |> Path.join(track.basename),
        srcUrl: "http://ocr.blueblue.fr/files/music/remixes" |> Path.join(track.basename),
        ocrUrl: "http://ocremix.org/music/OCR0#{track["TRCK"]}",
      }
    end
    tracks = get_tracklist |> Enum.filter(&(&1)) |> Enum.map(prep_track)
    render conn, "index.html", tracks: tracks
  end

  def tags(conn, params) do
    filename = params["filename"]
    file = File.read! "web/static/assets/mp3/#{filename}"
    frames = ID3v2.frames file
    render conn, "tags.html", frames: frames
  end

  def get_tracklist do
    GenServer.call IndexerWorker, :tracklist
  end

end
