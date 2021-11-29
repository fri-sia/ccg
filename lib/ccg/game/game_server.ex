defmodule Ccg.GameSettings do
  @enforce_keys [:player1, :player2, :player1_deck_list, :player2_deck_list]
  defstruct [:player1, :player2, :player1_deck_list, :player2_deck_list]
end

defmodule Ccg.GameServer do
  use GenServer
  alias Ccg.GameCard
  alias Ccg.Card

  defp make_deck(decklist) do
    decklist
    |> Enum.map(&GameCard.make/1)
  end

  @impl true
  @spec init(%Ccg.GameSettings{}) :: {:ok, any}
  def init(s) do
    player1_deck = make_deck(s.player1_deck_list)
    player2_deck = make_deck(s.player2_deck_list)
    initial_state = %{
      player1: %{
        controller: s.player1,
        health: 30,
        deck: player1_deck,
        hand: [],
        field: []
      },
      player2: %{
        controller: s.player2,
        health: 30,
        deck: player2_deck,
        hand: [],
        field: []
      },
      phase: :pre_game,
      needs_input_from: []
    }

    {:ok, initial_state}
  end

  def start(game_settings) do
    GenServer.start(__MODULE__, game_settings)
  end

  @impl true
  def handle_call(:get_all, _from, s) do
    {:reply, s, s}
  end

  # Api
  def get(server) do
    GenServer.call(server, :get_all)
  end

end
