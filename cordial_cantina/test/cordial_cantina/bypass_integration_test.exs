defmodule CordialCantina.BypassIntegrationTest do
  @moduledoc """
  Tests demonstrating Bypass HTTP mocking is available.

  These tests verify the testing infrastructure is correctly set up
  for mocking external API calls (Birdeye, Raydium, etc.) in future
  integration tests.
  """

  use ExUnit.Case, async: true
  use CordialCantina.BypassTestHelper

  describe "Bypass HTTP mocking" do
    test "can mock GET requests" do
      bypass = start_bypass()

      Bypass.expect_once(bypass, "GET", "/api/v1/test", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, ~s({"status": "ok", "data": [1, 2, 3]}))
      end)

      url = bypass_url(bypass, "/api/v1/test")
      {:ok, response} = Req.get(url)

      assert response.status == 200
      assert response.body["status"] == "ok"
      assert response.body["data"] == [1, 2, 3]
    end

    test "can mock POST requests with JSON body" do
      bypass = start_bypass()

      Bypass.expect_once(bypass, "POST", "/api/v1/submit", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)

        assert decoded["key"] == "value"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(201, ~s({"created": true}))
      end)

      url = bypass_url(bypass, "/api/v1/submit")
      {:ok, response} = Req.post(url, json: %{key: "value"})

      assert response.status == 201
      assert response.body["created"] == true
    end

    test "can simulate error responses" do
      bypass = start_bypass()

      Bypass.expect_once(bypass, "GET", "/api/v1/error", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(500, ~s({"error": "Internal server error"}))
      end)

      url = bypass_url(bypass, "/api/v1/error")
      # Disable retry to test error responses directly
      {:ok, response} = Req.get(url, retry: false)

      assert response.status == 500
      assert response.body["error"] == "Internal server error"
    end

    test "can simulate rate limiting" do
      bypass = start_bypass()

      Bypass.expect_once(bypass, "GET", "/api/v1/rate-limited", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("retry-after", "60")
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(429, ~s({"error": "Rate limit exceeded"}))
      end)

      url = bypass_url(bypass, "/api/v1/rate-limited")
      # Disable retry to test rate limiting response directly
      {:ok, response} = Req.get(url, retry: false)

      assert response.status == 429
      assert Req.Response.get_header(response, "retry-after") == ["60"]
    end
  end
end
