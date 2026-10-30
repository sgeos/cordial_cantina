defmodule CordialCantinaWeb.PageControllerTest do
  use CordialCantinaWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    body = html_response(conn, 200)
    assert body =~ "Cordial Cantina"
    assert body =~ "Concentrated Liquidity Market Maker for Solana"
  end
end
