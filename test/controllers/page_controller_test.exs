defmodule Ocjb.PageControllerTest do
  use Ocjb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end

  test "number_list empty", _conn do
    assert Ocjb.PageController.number_list [] = []
  end

  test "number_list 1 el", _conn do
    assert Ocjb.PageController.number_list [%{}] = [%{number: 1}]
  end

  test "number_list 2 el", _conn do
    assert Ocjb.PageController.number_list [%{a: 1}, %{b: 2}] = [%{number: 1, a: 1}, %{number: 2, b: 2}]
  end

end
