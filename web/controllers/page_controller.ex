defmodule Ocjb.PageController do
  use Ocjb.Web, :controller

  def index(conn, _params) do
    tracks = prep_track_data "web/static/assets/mp3"
    render conn, "index.html", tracks: tracks
  end

  def number_list(list) do
    accum = fn cur, {num, out} ->
      curout = Map.merge %{number: num}, cur
      {num+1, [curout | out]}
    end
    {_, out} = List.foldr list, {1,[]}, accum
    out
  end
  def prep_single_track(file) do
    trackmeta = extract_id3 file
    filemeta = %{
      ocrUrl: 'http://ocremix.org',
      srcUrl: "http://ocr.blueblue.fr/files/music/remixes" |> Path.join(Path.basename(file)),
    }
    Map.merge trackmeta, filemeta
  end
  def prep_track_data(folder) do
    list(folder) |> Enum.map(&prep_single_track/1) |> number_list
  end


# TODO This is Horrible. 
# TODO Use a module. 
# TODO Use ID3v2.
# TODO Get a fresh copy of tagged OCR tracks
# TODO Sweep tag metadata into memory instead of reading from disk every request
  def extract_metadata(file) do
    read_file = File.read!(file)
    file_length = byte_size(read_file)
    music_data = file_length - 128
    << _ :: binary-size(music_data), id3_section :: binary >> = read_file
    id3_section
  end
  defp parse_id3(metadata) do
    << _ :: binary-size(3), title :: binary-size(30), artist :: binary-size(30), album :: binary-size(30), _ :: binary >> = metadata
    %{
      title: sanitize(title),
      artist: sanitize(artist),
      album: sanitize(album)
    }
  end
  defp sanitize(text) do
    not_zero = &(&1 != <<0>>)
    text |> String.graphemes |> Enum.filter(not_zero) |> to_string |> String.strip
  end
  def extract_id3(file) do
    metadata = extract_metadata(file)
    parse_id3(metadata)
  end
  def extract_id3_list(folder) do
    folder |> list |> Enum.map(&extract_id3/1)
  end
  def list(folder) do
    folder |> Path.join("**/*.mp3") |> Path.wildcard
  end

end