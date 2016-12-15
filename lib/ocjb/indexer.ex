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
      |> Enum.concat(tracklist)
    {seen, tracklist}
  end

  def list(folder) do
    folder |> Path.join(@trackglob) |> Path.wildcard
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
      fullmeta: content |> ID3v2.frames |> Map.delete("COMM")
    }
  end

end
