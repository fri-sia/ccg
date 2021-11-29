defmodule Ccg.Cards.Warrior do
  use Ccg.Card

  def card_info() do
    %CardInfo{
      name: "Great Warrior",
      set: {:test, :origin},
    }
  end

  @spec base_card :: Ccg.BaseCard.t()
  def base_card(), do: %BaseCard{
    types: [:creature],
    creature: %{
      health: 4,
      attack: 2
    },
    permanent: %{}
  }
end
