defmodule FinancialSystem.Money do
  @moduledoc """
  A value structure to represent real world money.

  Every money must have a currency, and operations can be made only over money
  of the same currency. Amounts are represented as integers, for our application
  decimal separators aren't important for other than representation and aren't 
  taken in account during operations.
  """
  alias FinancialSystem.Money
  alias Money.Currency

  defstruct amount: 0, currency: :BRL

  @type t() :: %__MODULE__{
          amount: integer(),
          currency: Currency.t()
        }

  @doc """
  Creates a Money struct

  ## Examples
    iex> new(:BRL, 2000)
    %Money{currency: :BRL, amount: 2000}

    iex> new(:NONE, 2000)
    {:error, "Invalid Currency"}
  """
  @spec new(Currency.t(), integer()) :: t() | {:error, String.t()}
  def new(currency, amount) do
    with {:ok, _} <- Currency.possible_currency?(currency),
         {:ok, _} <- Money.possible_amount?(amount) do
      %Money{currency: currency, amount: amount}
    end
  end

  @doc """
  Increases a Money amount

  ## Examples
    iex> increase(%Money{amount: 2000, currency: :BRL}, %Money{amount:1000, currency: :BRL})
    %Money{amount: 3000, currency: :BRL}

    iex> increase(%Money{amount: 2000, currency: :BRL}, %Money{amount:1000, currency: :USD})
    {:error, "Can't operate over different currencies"}
  """
  @spec increase(t(), t()) :: t() | :error
  def increase(base, addition) do
    with {:ok, _} <- same_currency?(base, addition) do
      %{base | amount: base.amount + addition.amount}
    end
  end

  @doc """
  Sums a list of Money 
  """
  def sum([]), do: nil

  def sum(money_list) do
    money_list
    |> Enum.reduce(fn m, acc -> increase(acc, m) end)
  end

  @doc """
  Decreases a Money amount by another Money

  ## Examples
    iex> decrease(%Money{amount: 2000, currency: :BRL}, %Money{amount:1000, currency: :BRL})
    %Money{amount: 1000, currency: :BRL}

    iex> decrease(%Money{amount: 2000, currency: :BRL}, %Money{amount:1000, currency: :USD})
    {:error, "Can't operate over different currencies"}

  """
  @spec decrease(t(), t()) :: t() | {:error, String.t()}
  def decrease(base, decrementor) do
    with {:ok, _} <- same_currency?(base, decrementor) do
      if decrementor.amount >= base.amount do
        {:error, "Can't decrease this much"}
      else
        %{base | amount: base.amount - decrementor.amount}
      end
    end
  end

  @doc """
  Convert a money from a currency to another

  ## Examples
   iex> convert(%Money{amount: 200, currency: :BRL}, :USD)
   %Money{currency: :USD, amount: 200}
  """
  @spec convert(t(), Currency.t()) :: t() | {:error, String.t()}
  def convert(money, new_currency) do
    with {:ok, _} <- Currency.possible_currency?(new_currency) do
      %Money{amount: money.amount, currency: new_currency}
    end
  end

  @doc """
  Returns a percentage of a Money

  This can be used for split. Probably should take a look at the rest of the
  division as it is being ignored

  ## Examples
    iex> divide(%Money{currency: :BRL, amount: 200}, 30)
    %Money{currency: BRL, amount: 60}
  """
  @spec divide(t(), integer()) :: t() | {:error, String.t()}
  def divide(money, pct) do
    new_amount = div(money.amount * pct, 100)
    %Money{amount: new_amount, currency: money.currency}
  end

  @doc """
  Checks if two Money.t() are of the same currency

  ## Examples
    iex> same_currency(%Money{currency: :BRL}, %Money{currency: :USD})
    false
  """
  @spec same_currency?(t(), t()) :: {:ok, Currency.t()} | {:error, String.t()}
  def same_currency?(moneyA, moneyB) do
    with {:ok, currencyA} <- Map.fetch(moneyA, :currency),
         {:ok, currencyB} <- Map.fetch(moneyB, :currency) do
      case currencyA == currencyB do
        true -> {:ok, currencyA}
        false -> {:error, "Can't operate over different currencies"}
      end
    else
      :error -> {:error, "No currency given"}
    end
  end

  @doc """
  Checks if an amount is a possible amount

  ## Examples
    iex> possible_amount?(200)
    {:ok, 200}

    iex> possible_amount?("quatorze")
    {:error, "Amount must be an integer"}

    iex> possible_amount?(-200)
    {:error, "Amount can't be negative"}
  """
  @spec(possible_amount?(integer()) :: {:ok, integer()}, {:error, String.t()})
  def possible_amount?(amount) when not is_integer(amount),
    do: {:error, "Amount must be an integer"}

  def possible_amount?(amount) when amount < 0, do: {:error, "Amount can't be negative"}

  def possible_amount?(amount), do: {:ok, amount}

  @doc """
  Sums two money values if 1st exists, otherwise return 2nd 

  ## Examples
    iex> sum_if_exists(%Money{amount: 200, currency: :BRL}, %Money{amount: 200, currency: :BRL})
    %Money{amount: 400, currency: :BRL}

    iex> sum_if_exists(nil, %Money{amount: 200, currency: :BRL})
    %Money{amount: 200, currency: :BRL}
  """
  @spec sum_if_exists(Money.t() | nil, Money.t()) :: Money.t()
  def sum_if_exists(m1, m2) when is_nil(m1), do: m2
  def sum_if_exists(m1, m2), do: Money.increase(m1, m2)

  @doc """
  Returns an error if the 1st money is smaller than the 2nd

  ## Examples
  iex> has_enough(%Money{amount: 200, currency: :BRL}, %Money{amount: 250, currency: :BRL})
  {:error, "Not enough money for this operation"}

  iex> has_enough(%Money{amount: 300, currency: :BRL}, %Money{amount: 250, currency: :BRL})
  {:ok, %Money{amount: 300, currency: :BRL}}

  """
  def has_enough(%{amount: a1} = m1, %{amount: a2}) when a1 > a2, do: {:ok, m1}
  def has_enough(_, _), do: {:error, "Not enough money for this transfer"}
end
