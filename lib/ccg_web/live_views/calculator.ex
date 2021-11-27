defmodule CcgWeb.CalculatorLive do
  use CcgWeb, :live_view

  defp parse(num) do
    {number, _r} = Float.parse(num)
    number
  end

  defp has_decimal(num) do
    String.match?(num, ~r/\./)
  end

  defp parse_operator(op) do
    case op do
      "+" -> :plus
      "-" -> :minus
      "*" -> :times
    end
  end

  defp reduce(exprs) do
    exprs = case exprs do
      [a, op, b | r] -> [parse(a), op, parse(b) | r]
      exprs -> exprs
    end
    case exprs do
      [a, :plus, b | r] -> [to_string(a + b) | r]
      [a, :minus, b | r] -> [to_string(b - a) | r]
      [a, :times, b | r] -> [to_string(b * a) | r]
      exprs -> exprs
    end
  end

  def mount(_params, _session, socket) do
    socket = socket |> assign(:stack, [])
    {:ok, socket}
  end

  def handle_event("digit", %{"value" => d}, socket) do
    stack = case socket.assigns.stack do
      [] -> [d]
      [op | r] when is_atom(op) -> [d | [op | r]]
      [num | r] -> if num == "0", do: [d | r], else: ["#{num}#{d}" | r]
    end
    socket = assign socket, :stack, stack
    {:noreply, socket}
  end

  def handle_event("decimal", _v, socket) do
    stack = case socket.assigns.stack do
      [num | r] when is_binary(num) -> if has_decimal(num), do: [num | r], else: ["#{num}." | r]
      exprs -> ["0." | exprs]
    end
    socket = assign socket, :stack, stack
    {:noreply, socket}
  end

  def handle_event("operator", %{"value" => v}, socket) do
    op = parse_operator(v)
    stack = case socket.assigns.stack do
      [] -> [op, "0"]
      [num] when is_binary(num) -> [op, num]
      [other_op | r] when is_atom(other_op) -> [op | r]
      exprs -> [op | reduce(exprs)]
    end
    socket = assign socket, :stack, stack
    {:noreply, socket}
  end

  def handle_event("calculate", _v, socket), do: {:noreply, update(socket, :stack, &reduce/1)}
  def handle_event("reset", _v, socket), do: {:noreply, assign(socket, :stack, [])}

  defp render_expr(expr) do
    case expr do
      :plus -> "+"
      :minus -> "-"
      :times -> "*"
      num -> num
    end
  end

  def render_exprs(exprs) do
    res = exprs
      |> Enum.reverse()
      |> Enum.map(&render_expr/1)
      |> Enum.join(" ")
    case res do
      "" -> "0"
      other -> other
    end
  end
end
