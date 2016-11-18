defmodule Ocjb.PageHelpers do

  @moduledoc """
  Conveniences for page elements
  """

  use Phoenix.HTML

  @base_url_ocrmirror "http://ocrmirror.org/files/music/remixes"
  @base_url_blueblue "http://ocr.blueblue.fr/files/music/remixes"
  @base_url_aplus "http://iterations.org/files/music/remixes"

  @doc """
  Constructs a URL to a track's OC ReMix page
  """
  def ocr_url(track) do
    number = track.fullmeta["TRCK"]
    "http://ocremix.org/remix/OCR#{number |> String.rjust(5, ?0)}"
  end

  @doc """
  Builds a URL to Aplus download
  """
  def aplus_url(track) do
    _download_url @base_url_aplus, track.basename
  end

  @doc """
  Builds a URL to BlueBlue.fr download
  """
  def blueblue_url(track) do
    _download_url @base_url_blueblue, track.basename
  end

  @doc """
  Builds a URL to ocrmirror.org download
  """
  def ocrmirror_url(track) do
    _download_url @base_url_ocrmirror, track.basename
  end

  defp _download_url(base_url, basename) do
    base_url |> Path.join(basename)
  end

end
