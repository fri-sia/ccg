defmodule Ccg.CardTest do
  use ExUnit.Case
  alias Ccg.Card

  setup do
    cards = Card.all_cards()
    %{cards: cards}
  end

  test "can get all cards", %{cards: cards} do
    assert Enum.count(cards) > 0
  end
end
