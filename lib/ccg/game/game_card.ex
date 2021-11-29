
defmodule Ccg.GameCard do
  @enforce_keys [:base_card, :card_info]
  defstruct [:base_card, :card_info, modifiers: []]

  @typedoc """

  """
  @type t :: %__MODULE__{
    base_card: Ccg.BaseCard.t,
    card_info: Ccg.CardInfo.t,
    modifiers: [any]
  }

  @spec make(card :: module()) :: __MODULE__.t
  def make(card) do
    %__MODULE__{
      base_card: card.base_card(),
      card_info: card.card_info(),
      modifiers: []
    }
  end
end
