defmodule Morra.RoomServer do
  @moduledoc false

  use GenServer

  def start_link(opts) do
      #GenServer.start_link __MODULE__, %{}
      GenServer.start_link(__MODULE__, [], name: RoomServer)
    end


  def init(_state) do
    MorraWeb.Endpoint.subscribe "room:lobby", []
    {:ok, []}
  end

  def get_players_list() do
    GenServer.call(RoomServer, :players_list)
  end

  def remove_player(player_id) do
    GenServer.call(RoomServer, {:remove_player, player_id})
  end

  def add_player() do
    case GenServer.call(RoomServer, :add_player) do
    1 -> {:ok, 1}
    2 -> {:ok, 2}
    :error -> {:error, "More than 2 players not allowed!"}
    end
    #{:ok, 1}
  end

  def choose_weapon(player_id, weapon) do
    case GenServer.call(RoomServer, {:choose_weapon, player_id, weapon}) do
      {:winner, winner} -> {:winner, winner}
      other_result -> other_result
    end
  end

  def reset_game() do
    GenServer.call(RoomServer, :replay)
  end

  #SERVER

  def handle_call(:add_player, _from, state) do
    case Enum.count(state) do
      0 ->
       {:reply, 1, [%{id: 1, weapon: ""} | state]}
      1 ->
        {:reply, 2, [%{id: 2, weapon: ""} | state]}
      _ -> {:reply, :error, state}
    end
  end

  def handle_call(:players_list, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:replay, _from, state) do
    new_state = Enum.map(state, &(%{&1 | weapon: ""}))
    {:reply, new_state, new_state}
  end

  def handle_call({:choose_weapon, player_id, weapon}, _from, state) do
    new_state = Enum.map(state, fn (player) -> if player.id == player_id, do: player = %{player | weapon: weapon}, else: player end)

    if (Enum.count(state) == 2), do: {:reply, answer_for(new_state), new_state}, else: {:reply, :other, new_state}
  end

  defp answer_for(players) do
    all_players_moved = players |> Enum.map(&(&1.weapon)) |> Enum.all?(&(&1 != ""))
    if all_players_moved, do: find_winner(players)
  end

  defp find_winner(players) do
    is_winner = fn current -> beat_all?(current.weapon, List.delete(players, current)) end
    winner = Enum.find(players, is_winner)

    if winner, do: {:winner, winner}, else: :draw
  end

  def handle_call({:remove_player, player_id}, _from, state) do
    new_state = Enum.filter(state, &(&1.id != player_id))
    {:reply, :ok, state}
  end

  defp beat_all?(weapon, players) do
    this_beat_that = %{"rock" => "scissors",
                       "paper" => "rock",
                       "scissors" => "paper"}

    weapon_that_i_beat = Map.get(this_beat_that, weapon)

    Enum.all?(players, &(&1.weapon == weapon_that_i_beat))
  end

end
