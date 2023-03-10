defmodule TasteBuddyWeb.Live do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
      <div class="control_panel">
        <form phx-submit="truck_search">
          <%= # <button phx-click="load_data" >RE-LOAD</button> %>
          <button phx-click="pick_truck" >RANDOM!</button>
          <button type="submit">Search:</button>
          <input type="text" name="search_string" placeholder="search by name or food" />
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
    send(self(), :pick_truck)

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

  def handle_info(:pick_truck, socket) do
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

  def handle_event("pick_truck", _, socket) do
    send(self(), :pick_truck)

    {:noreply, socket}
  end

  def handle_event("truck_search", %{"search_string" => search_string}, socket) do
    pick =
      Enum.filter(
        socket.assigns.food_trucks,
        fn %{"Applicant" => name, "FoodItems" => food} = truck ->
          crude_search(truck, search_string) and
            truck != socket.assigns.pick
        end
      )
      |> Enum.random()

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
