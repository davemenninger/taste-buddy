defmodule TasteBuddyWeb.Router do
  use TasteBuddyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TasteBuddyWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", TasteBuddyWeb do
    pipe_through :browser
    live "/", Live
  end
end
