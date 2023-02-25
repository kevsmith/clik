defmodule Clik.Output.Text do
  defstruct [:eol?, :code, :text]

  @type t :: %__MODULE__{}

  @spec new(atom(), bitstring(), boolean()) :: t()
  def new(code \\ nil, text, include_eol) do
    %__MODULE__{code: code, text: text, eol?: include_eol}
  end

  @spec append(t(), bitstring()) :: t()
  def append(t, new_text) do
    %{t | text: t.text <> new_text}
  end
end

defimpl Clik.Renderable, for: Clik.Output.Text do
  alias IO.ANSI
  alias Clik.Output.Platform

  def render(text, out) do
    output =
      if text.code != nil do
        ANSI.format([text.code, text.text]) |> :erlang.iolist_to_binary()
      else
        text.text
      end

    result =
      if text.eol? do
        IO.write(out, output <> Platform.eol_char())
      else
        IO.write(out, output)
      end

    if result == :ok do
      {:ok, out}
    else
      {:error, :io}
    end
  end
end