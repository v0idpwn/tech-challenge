defmodule FinancialSystem.Wallet do
  @moduledoc """
  Abstracts Account Money handling.
  
  The wallet is where the money lives. Takes care of avoiding duplication, 
  which could be disastrous. Can't be simply compared (as money) because 
  ordering matters.
  """
  alias FinancialSystem.Money
  alias Money.Currency

  @type t() :: list(Money.t())

  @doc """
  Creates a new wallet from a list of Money
  """
  @spec new([Money.t()]) :: t()
  def new([]), do: []

  def new(money_list) do
    Enum.map(Currency.get_currencies(), fn c -> unify(money_list, c) end)
    |> Enum.filter(& &1)
  end

  @doc """
  Unify moneys of the same currency in a money list into a unique money struct
  """
  @spec unify([Money.t()], Currency.t()) :: Money.t()
  def unify(ml, currency) do
    Enum.filter(ml, fn m -> m.currency == currency end)
    |> Money.sum()
  end

  @doc """
  Updates a wallet with a new money value
  """
  @spec update(t(), Money.t()) :: t()
  def update(wallet, money) do
    [
      money
      | Enum.filter(wallet, fn m -> m.currency != money.currency end)
    ]
  end

  @doc """
  Returns a Money struct from an wallet
  """
  @spec get_money(t(), Currency.t()) :: Money.t()
  def get_money(wallet, currency) do
    Enum.find(wallet, fn m -> m.currency == currency end)
  end
end
