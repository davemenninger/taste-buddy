defmodule TasteBuddyWeb.PageControllerTest do
  use TasteBuddyWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Search:"
  end
end
