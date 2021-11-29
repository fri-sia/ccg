
defmodule Ccg.BaseCard do
  @enforce_keys [:types]
  defstruct [:types, :creature, :permanent]

  @typedoc """
  Base card info
  """
  @type t :: %__MODULE__{
    types: [:creature | :spell],
    creature: Map.t() | nil,
    permanent: Map.t() | nil
  }
end

defmodule Ccg.CardInfo do
  @enforce_keys [:set]
  defstruct [:set, :name, references: []]

  @typedoc """
  Meta card info for a card.

  * `references` a list of card the card references in card text. Tokens for example
  """
  @type t :: %__MODULE__{
    set: {:test | :main | :token, atom()},
    name: String.t(),
    references: [module()]
  }
end

defmodule Ccg.Card do
  @callback base_card() :: Ccg.BaseCard.t()
  @callback card_info() :: Ccg.CardInfo.t

  @doc """
  Checks if a module is a card module
  """
  @spec is_card?(module()) :: boolean()
  def is_card?(module) do
    :attributes
    |> module.module_info()
    |> Enum.member?({:behaviour, [__MODULE__]})
  end

  @spec all_cards :: :undefined | list
  @doc """
  Scans all registered modules under the namespace Ccg.Cards
  to get card information for all the modules.
  """
  def all_cards() do
    with {:ok, list} <- :application.get_key(:ccg, :modules) do
      list
      |> Enum.filter(& &1 |> Module.split |> Enum.take(2) == ~w|Ccg Cards|)
      |> Enum.filter(&is_card?/1)
      |> Enum.map(& {&1, &1.card_info()})
    end
  end

  defmacro __using__(_opts) do
    quote do
      @behaviour Ccg.Card
      alias Ccg.Card
      alias Ccg.BaseCard
      alias Ccg.CardInfo

      def test_callback(), do: "hej"

      defoverridable [test_callback: 0]
    end
  end
end
