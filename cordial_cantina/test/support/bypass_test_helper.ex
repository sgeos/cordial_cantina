defmodule CordialCantina.BypassTestHelper do
  @moduledoc """
  Helper module for HTTP mocking with Bypass.

  ## Usage

  In your test file:

      use CordialCantina.BypassTestHelper

      test "mock external API" do
        bypass = start_bypass()

        Bypass.expect_once(bypass, "GET", "/api/data", fn conn ->
          Plug.Conn.resp(conn, 200, ~s({"status": "ok"}))
        end)

        # Make HTTP request to bypass_url(bypass, "/api/data")
        # Assert response
      end

  ## Available Functions

  - `start_bypass/0` - Start a new Bypass instance
  - `bypass_url/2` - Get the URL for a Bypass instance and path
  """

  defmacro __using__(_opts) do
    quote do
      import CordialCantina.BypassTestHelper
    end
  end

  @doc """
  Starts a new Bypass instance for mocking HTTP requests.
  """
  def start_bypass do
    Bypass.open()
  end

  @doc """
  Returns the full URL for a Bypass instance and path.
  """
  def bypass_url(bypass, path \\ "/") do
    "http://localhost:#{bypass.port}#{path}"
  end
end
