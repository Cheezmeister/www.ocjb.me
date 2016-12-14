defmodule Ocjb.Indexer do

  require Logger

  use GenServer
  
  @trackglob "*.mp3"
  @batchsize 50
  @interval_seconds 20

  def start_link(_previousState, opts) do
    GenServer.start_link(__MODULE__, {%{}, []}, opts)
  end

  def init(state) do
    schedule_work
    {:ok, prep_tracklist(state)}
  end

  def schedule_work do
    Process.send_after(self(), :work, @interval_seconds * 1000)
  end

  def handle_info(:work, state) do
    schedule_work
    {:noreply, prep_tracklist(state)}
  end

  def handle_call(:tracklist, _from, state) do
    {_, tracklist} = state
    {:reply, tracklist, state}
  end

  def prep_tracklist({seen, tracklist}) do
    folder = Application.get_env(:ocjb, Ocjb.Endpoint)[:music_dir]
    files = list(folder) 
      |> Enum.filter(fn f -> !(seen[f]) end)
      |> Enum.take(@batchsize)
    Logger.info "Indexing: #{files |> Enum.join(",")}"
    seen = files |> Enum.zip(files |> Enum.map(fn(_)->true end)) |> Enum.into(%{}) |> Map.merge(seen)
    tracklist = files
      |> Enum.map(&prep_single_track/1) 
      |> number_list
      |> Enum.concat(tracklist)
    {seen, tracklist}
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
    Logger.debug "Reading tags from #{file}"
    case File.read(file) do
      {:ok, ""} -> nil # Empty file
      {:ok, content} -> extract_id3v2(content, file)
      {err, reason} -> raise "Couldn't read #{file}: #{err}: #{reason}"
    end
  end

  def extract_id3v2(content, file) do
    %{
      basename: Path.basename(file),
      fullmeta: content |> ID3v2.frames
    }
  end


  # def extract_id3(file) do
  #   metadata = extract_metadata(file)
  #   parse_id3(metadata)
  # end

  # def extract_metadata(file) do
  #   read_file = File.read!(file)
  #   file_length = byte_size(read_file)
  #   music_data = file_length - 128
  #   << _ :: binary-size(music_data), id3_section :: binary >> = read_file
  #   id3_section
  # end

  # defp parse_id3(metadata) do
  #   << _ :: binary-size(3), title :: binary-size(30), artist :: binary-size(30), album :: binary-size(30), _ :: binary >> = metadata
  #   %{
  #     title: sanitize(title),
  #     artist: sanitize(artist),
  #     album: sanitize(album)
  #   }
  # end

  # defp sanitize(text) do
  #   not_zero = &(&1 != <<0>>)
  #   text |> String.graphemes |> Enum.filter(not_zero) |> to_string |> String.strip
  # end

end
