defmodule ID3v2 do
  require Bitwise
  use Bitwise

  defmodule HeaderFlags do
    defstruct [:unsynchronized, :extended_header, :experimental]

    @unsynchronized_bit 128
    @extended_header_bit 64
    @experimental_bit 32

    def read(byte) do
      %HeaderFlags{
        experimental: 0 != Bitwise.band(byte, @experimental_bit),
        unsynchronized: 0 != Bitwise.band(byte, @unsynchronized_bit),
        extended_header: 0 != Bitwise.band(byte, @extended_header_bit),
      }
    end
  end

  defmodule Frame do
    defstruct [:key, :value, :encoding, :size]
  end

  @doc"""
  TODO
  """
  def header(filecontents) do
    << "ID3",
    version :: binary-size(2),
    flags :: integer-8,
    size :: binary-size(4),
    _ :: binary >> = filecontents

    << versionMajor, versionMinor >> = version
    flags = read_flags(flags)
    if flags.extended_header do
      raise "This tag has an extended header. Extended header is not supported."
    end

    header = %{
      version: {versionMajor, versionMinor},
      flags: flags,
      size: unpacked_size(size) }

    header
  end

  @doc"""
  TODO
  """
  def read_flags(byte) do
    HeaderFlags.read byte
  end

  @doc"""
  TODO
  """
  def unpacked_size(quadbyte) do
    << byte1, byte2, byte3, byte4 >> = quadbyte
    byte4 + (byte3<<<7) + (byte2<<<14) + (byte1<<<21)
  end

  def frames(filecontent) do
    headerSize = header(filecontent).size
    << _header :: binary-size(10), framedata :: binary-size(headerSize), _ :: binary >> = filecontent

    _read_frames(framedata)
  end

  # Handle padding bytes at the end of the tag
  def _read_frames(<<0, _ :: binary>>) do
    %{}
  end
  def _read_frames(framedata) do

    << frameheader :: binary-size(10), rest :: binary >> = framedata
    << key :: binary-size(4), size :: integer-32, _flags :: binary-size(2) >> = frameheader
    # TODO handle flags
    # TODO handle synchsafe size if version 2.4
    # TODO Handle optional language prefix
    pldSize = size
    << payload :: binary-size(pldSize), rest :: binary >> = rest

    value = read_payload key, payload
    IO.puts "#{key}: #{value}"

    Map.merge %{key => value}, _read_frames(rest)
  end

  def read_payload(key, payload) do
    << _encoding :: integer-8, _rest :: binary>> = payload

    # Special case nonsense goes here
    case key do
      "WXXX" -> read_user_url payload
      "APIC" -> nil # Ignore embedded JPEG data
      _ -> read_standard_payload payload
    end
  end

  def read_standard_payload(payload) do
    << encoding :: integer-8, rest :: binary>> = payload
    case encoding do
      0 -> rest
      1 -> read_utf16 rest
      2 -> raise "I don't support utf16 without a bom"
      3 -> rest
      _ -> payload
    end
  end

  def read_utf16(<< bom :: binary-size(2), content :: binary >>) do
    {encoding, _charsize} = :unicode.bom_to_encoding(bom)
    :unicode.characters_to_binary content, encoding
  end

  # Based on https://elixirforum.com/t/scanning-a-bitstring-for-a-value/1852/2
  def read_user_url(payload) do
    # TODO bubble up description somehow
    {_description, link} = extract_null_terminated payload
    link
  end
  def extract_null_terminated(bitstr) do
    << encoding::integer-8, rest::binary >> = bitstr
    case encoding do
      1 -> 
        << _bom :: binary-size(2), content :: binary >> = rest
        scan_for_null_utf16 content, []
      _ -> raise "I don't support non-UTF16 null-terminated front matter"
    end
  end
  def scan_for_null_utf16(<< 0::utf16, rest::binary >>, accum) do
    {to_string(Enum.reverse accum), rest}
  end
  def scan_for_null_utf16(<< c::utf16, rest::binary >>, accum) do
    scan_for_null_utf16 rest, [c | accum]
  end

end
