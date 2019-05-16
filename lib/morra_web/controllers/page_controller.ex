defmodule MorraWeb.PageController do
  use MorraWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
