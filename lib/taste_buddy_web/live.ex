defmodule TasteBuddyWeb.Live do
  use Phoenix.LiveView

  @doc """
  NOTES:

  Design choices:
  * used LivewView to load the csv in the background and allow searching without a page reload.
  * the LiveView Component can be reused if displaying all of the matching results, instead of choosing only one to
  show.

  Would have liked to add:
  * stats/counts, like: "out of X entries, there are Y matches. here is a random one of those."
  * show more of the data from the file, especially a map.
  * better search (fuzzy matching?); bold/highlight the matching term.
  * tests covering the load_data_from_csv and crude_search functions

  Known not-working:
  * the search term disappears from the search box, after hitting submit. i'd like it to stay, and maybe have a "give
  me another option". button for the same search term.
  * didn't get to extensively test the Dockerfile

  """

  def render(assigns) do
    ~H"""
      <div class="control_panel">
        <form phx-submit="truck_search">
          <%= # <button phx-click="load_data" >RE-LOAD</button> %>
          <button type="button" phx-click="pick_random_truck" >RANDOM!</button>
          <button type="submit">Search:</button>
          <input type="text" name="search_string" placeholder="search by name or by food" />
        </form>
      </div>

      <div>
        <%= live_component(TasteBuddyWeb.Live.Pick, id: :pick, pick: @pick) %>
      </div>
    """
  end

  def mount(_params, _, socket) do
    socket =
      socket
      |> assign(:food_trucks, [])
      |> assign(:pick, %{})

    send(self(), :load_data)
    send(self(), :pick_random_truck)

    {:ok, socket}
  end

  def handle_info(:load_data, socket) do
    {:noreply,
     socket
     |> assign(
       :food_trucks,
       TasteBuddy.FileLoader.load_data_from_csv()
     )}
  end

  def handle_info(:pick_random_truck, socket) do
    pick =
      case socket.assigns.food_trucks do
        [] -> "..."
        food_trucks -> Enum.random(food_trucks)
      end

    {:noreply,
     socket
     |> assign(:pick, pick)}
  end

  def handle_event("load_data", _, socket) do
    send(self(), :load_data)

    {:noreply, socket}
  end

  def handle_event("pick_random_truck", _, socket) do
    send(self(), :pick_random_truck)

    {:noreply, socket}
  end

  def handle_event("truck_search", %{"search_string" => search_string}, socket) do
    pick =
      case Enum.filter(
             socket.assigns.food_trucks,
             fn %{"Applicant" => _name, "FoodItems" => _food} = truck ->
               crude_search(truck, search_string) and
                 truck != socket.assigns.pick
             end
           ) do
        [] -> %{"Applicant" => "n/a", "FoodItems" => "no match"}
        matches -> matches |> Enum.random()
      end

    {:noreply,
     socket
     |> assign(:pick, pick)}
  end

  defp crude_search(%{"Applicant" => name, "FoodItems" => food}, search_string) do
    terms = [name, food]

    Enum.reduce(
      terms,
      false,
      fn term, acc ->
        acc or
          term
          |> String.downcase()
          |> String.contains?(String.downcase(search_string))
      end
    )
  end
end

defmodule TasteBuddyWeb.Live.Pick do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
      <div class="food_truck">
        <p>
          <strong>Name:</strong> <%= @pick["Applicant"] %>
        </p>
        <p>
          <strong>Food Items:</strong> <%= @pick["FoodItems"] %>
        </p>
        <p>
          <strong>Map goes here: </strong> <%= @pick["Latitude"] %>, <%= @pick["Longitude"] %>
        </p>
      </div>
    """
  end
end
