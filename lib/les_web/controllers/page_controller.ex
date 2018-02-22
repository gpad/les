defmodule LesWeb.PageController do
  use LesWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
