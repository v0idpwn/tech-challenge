defmodule FinancialSystem.Money.Currency do
  @moduledoc """
  ISO currencies are composed by code, number and a decimal separator.

  We use atoms to represent 
  """
  @type t() ::
          :BRL
          | :USD
          | :EUR

  @currencies [:BRL, :USD, :EUR]

  @doc """
  Checks if a currency can be used
  """
  @spec possible_currency?(any()) :: {:ok, t()} | {:error, String.t()}
  def possible_currency?(currency) do
    case Enum.member?(@currencies, currency) do
      true -> {:ok, currency}
      false -> {:error, "Invalid currency"}
    end
  end

  @doc """
  Show ISO details about a currency

  We probably could carry this data but I don't see the point
  """
  @spec details(t()) :: map() | {:error, String.t()}
  def details(:BRL), do: %{code: :BRL, number: 986, decimal_separator: 2}
  def details(:USD), do: %{code: :USD, number: 840, decimal_separator: 2}
  def details(:EUR), do: %{code: :EUR, number: 978, decimal_separator: 2}
  def details(_), do: {:error, "This currency doesn't exist!"}


  @doc """
  Expose module attribute as a function to external modules
  """
  def get_currencies, do: @currencies
end
