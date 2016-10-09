defmodule Ocjb.Indexer do

  use GenServer

  @folder "web/static/assets/mp3"
  @trackglob "**/*.mp3"

  def start_link(_previousState, opts) do
    :timer.sleep 2000
    state = prep_tracklist
    GenServer.start_link(__MODULE__, state, opts)
  end

  def handle_call(:tracklist, _from, tracklist) do
    {:reply, tracklist, tracklist}
  end

  def prep_tracklist do
    list(@folder) |> Enum.map(&prep_single_track/1) |> number_list
  end

  def list(folder) do
    folder |> Path.join(@trackglob) |> Path.wildcard
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
    fullmeta = File.read!(file) |> ID3v2.frames
    basename = Path.basename(file)
    filemeta = %{
      ocrUrl: "http://ocremix.org/music/OCR0#{fullmeta["TRCK"]}",
      srcUrl: "http://ocr.blueblue.fr/files/music/remixes" |> Path.join(basename),
      devUrl: "/mp3" |> Path.join(basename),
      basename: basename,
      fullmeta: fullmeta
    }
    Map.merge trackmeta, filemeta
  end


# TODO Use ID3v2.
# TODO Get a fresh copy of tagged OCR tracks
# TODO Sweep tag metadata into memory instead of reading from disk every request
  def extract_id3(file) do
    metadata = extract_metadata(file)
    parse_id3(metadata)
  end

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

end
