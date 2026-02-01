defmodule CordialCantinaWeb.PageController do
  use CordialCantinaWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
