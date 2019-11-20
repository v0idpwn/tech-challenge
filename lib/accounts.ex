defmodule FinancialSystem.Account do
  @moduledoc """
  Accounts are this system's representation of an user. 

  This module offers an interface for creating an account and updating its
  wallet. 
  """
  alias FinancialSystem.Money
  alias FinancialSystem.Account
  alias FinancialSystem.Wallet

  @name_regex ~r/^[A-ZÀ-Ÿ][A-zÀ-ÿ']+\s([A-zÀ-ÿ']\s?)*[A-ZÀ-Ÿ][A-zÀ-ÿ']+$/
  defstruct name: "Gendo Ikari", wallet: []

  @type t() :: %__MODULE__{
          name: String.t(),
          wallet: [Money.t()]
        }

  @doc """
  Creates an Account struct
  """
  @spec new(String.t(), [Money.t()]) :: t() | {:error, String.t()}
  def new(name, money_list) do
    with {:ok, _} <- Account.valid_name?(name),
         wallet <- Wallet.new(money_list) do
      %Account{name: name, wallet: wallet}
    end
  end

  @doc """
  Updates an account wallet with a new money value
  """
  @spec put_money(t(), Money.t()) :: t()
  def put_money(acc, money) do
    acc
    |> Map.put(:wallet, Wallet.update(acc.wallet, money))
  end

  @doc """
  Returns an error if a name isn't valid
  """
  def valid_name?(name) when is_binary(name) do
    case String.match?(name, @name_regex) do
      true -> {:ok, name}
      false -> {:error, "Invalid name!"}
    end
  end

  def valid_name?(_), do: {:error, "Name must be a string!"}
end
