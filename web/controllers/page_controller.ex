defmodule Ocjb.PageController do
  use Ocjb.Web, :controller

  def index(conn, _params) do
    tracks = [
      %{number: 1, title: 'Title A', artist: 'Jon Snow', ocrUrl: 'http://ocremix.org', srcUrl: '/dummy.mp3'},
      %{number: 2, title: 'Title B', artist: 'Jivemaster', ocrUrl: 'http://ocremix.org', srcUrl: '/dummy.mp3'},
    ]
    render conn, "index.html", tracks: tracks
  end
end
