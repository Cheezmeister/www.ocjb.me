defmodule ID3v2Test do
  use ExUnit.Case

  test "header extraction" do
    file = File.read!("web/static/assets/mp3/Sonic_the_Hedgehog_2_Above_the_Sky_OC_ReMix.mp3")
    header = ID3v2.header(file)
    assert header.version == {4, 0}
    assert header.flags.unsynchronized
    assert header.size == 73497
  end

  test "header unsynchronized flag" do
    assert ID3v2.read_flags(128).unsynchronized
  end

  test "header extended_header flag" do
    assert ID3v2.read_flags(64).extended_header
  end

  test "header experimental flag" do
    assert ID3v2.read_flags(32).experimental
  end

  test "header size extraction" do
    assert ID3v2.unpacked_size(<< 0, 4, 62, 25 >>) == 25 + (62*128) + (4*128*128) + (0)
  end

  test "read UTF-16" do
    assert "A0" == ID3v2.read_utf16 << 255, 254, 65, 00, 48, 00 >>
  end

  test "read payload ASCII/ISO-8859-1" do
    assert "pants" == ID3v2.read_payload "XXXX", << 0, "pants" :: utf8 >>
  end

  test "read payload UTF-16" do
    assert "pants" == ID3v2.read_payload "XXXX", << 1, 255, 254, "pants" :: utf16-little >>
    assert "pants" == ID3v2.read_payload "XXXX", << 1, 254, 255, "pants" :: utf16-big >>
  end

  test "read payload UTF-8" do
    assert "pants" == ID3v2.read_payload("XXXX", << 3, "pants" :: utf8 >>)
  end

  test "frame data" do
    frames = ID3v2.frames(File.read!("ats_new.mp3"))
    assert frames["TALB"] == "http://ocremix.org"
  end

  test "extract null-terminated" do
    {description, rest} = ID3v2.extract_null_terminated << 1, 255, 254, "Wat"::utf16, 00, 00, 65, 66, 67 >>
    assert description == "Wat"
    assert rest == "ABC"
  end

end
