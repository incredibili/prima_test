defmodule MorraWeb.RoomChannel do
  @moduledoc false
  use MorraWeb, :channel

  def join("room:lobby", payload, socket) do
        case Morra.RoomServer.add_player() do
        {:ok, player_id} ->
           socket = socket
             |> assign(:player_id, player_id)
          case player_id do
          1 -> send self, :waiting_for_player
          2 -> send self, :ready_for_match
          end
        {:ok, socket}
        {:error, reason} -> {:error, reason}
        end
  end

  def handle_info(:ready_for_match, socket) do
    broadcast_match_ready(socket)

    {:noreply, socket}
  end

  def handle_info(:waiting_for_player, socket) do
    broadcast_waiting_player(socket)

    {:noreply, socket}
  end

  def handle_in("choose_weapon", %{"weapon" => weapon}, socket) do
    player_id = socket.assigns.player_id
    case Morra.RoomServer.choose_weapon(player_id, weapon) do
      {:winner, winner} ->
        broadcast! socket, "result_found", %{"message" => "#{winner.id}"}

      :draw ->
        broadcast! socket, "result_found", %{"message" => "0"}

      _ -> nil
    end

    {:noreply, socket}
  end

  def handle_in("replay", _, socket) do
    Morra.RoomServer.reset_game()
    broadcast_players_change(socket)
    broadcast! socket, "replay", %{}
    {:noreply, socket}
  end

  def handle_in("leave", _, socket) do
    player_id = socket.assigns.player_id

    Morra.RoomServer.remove_player(player_id)
    broadcast_players_change(socket)

    {:stop, :normal, :ok, socket}
  end

  def handle_in("get_id", payload, socket) do
    player_id = socket.assigns.player_id
    {:reply, {:ok, %{player_id: player_id}}, socket}
  end

  defp broadcast_match_ready (socket) do
  broadcast! socket, "ready_for_match", %{}
  end

  defp broadcast_waiting_player (socket) do
  broadcast! socket, "waiting_for_player", %{}
  end

  defp broadcast_players_change(socket) do
    players = Morra.RoomServer.get_players_list()
    broadcast! socket, "players_changed", %{players: Enum.reverse(players)}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end
  # Add authorization logic here as required.

  #defp authorized?(_payload) do
  #  true
  #end
end
