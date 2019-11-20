defmodule FinancialSystem do
  @moduledoc """
  Documentation for FinancialSystem.
  """
  alias FinancialSystem.Money
  alias FinancialSystem.Account
  alias FinancialSystem.Wallet
  alias Money.Currency

  @doc """
  Transfer amount from an Account to another
  """
  @spec transfer(Account.t(), Account.t(), Money.t()) :: map() | {:error, String.t()}
  def transfer(sender, receiver, transferred) do
    with sender_money <- Wallet.get_money(sender.wallet, transferred.currency),
         receiver_money <- Wallet.get_money(receiver.wallet, transferred.currency),
         {:ok, _} <- Money.has_enough(sender_money, transferred),
         after_send <- Money.decrease(sender_money, transferred),
         after_receive <- Money.sum_if_exists(receiver_money, transferred) do
      %{
        sender: Account.put_money(sender, after_send),
        receiver: Account.put_money(receiver, after_receive)
      }
    end
  end

  @doc """
  Does a transfer from an account to a list of accounts

  ## Examples
  iex> split_transfer(%Account{...},  
    [ {%Account{...}, 10}, 
      {%Account{...}, 80}, 
      {%Account{...}, 10}
    ], 
    %Money{amount: 2900, currency: :BRL})
  %{sender: %Account{...}, receivers: [%Account{..}, ...]}
  """
  @spec split_transfer(Account.t(), [{Account.t(), integer()}], Money.t()) ::
          map() | {:error, String.t()}
  def split_transfer(sender, receivers, transferred) do
    with sender_money <- Wallet.get_money(sender.wallet, transferred.currency),
         {:ok, _} <- Money.has_enough(sender_money, transferred),
         {:ok, _} <- valid_split(receivers) do
      r_list =
        Enum.map(receivers, fn r ->
          transfer(
            sender,
            elem(r, 0),
            Money.divide(transferred, elem(r, 1))
          )
          |> Map.fetch!(:receiver)
        end)

      after_send = Money.decrease(sender_money, transferred)

      %{sender: Account.put_money(sender, after_send), receivers: r_list}
    end
  end

  @doc """
  Convert from a currency to another 

  Could put some exchange rates in Money.convert
  
  ## Examples
  iex> exchange(%Account{...}, %Money{amount: 2900, currency: :BRL}, :USD)
  %Account{...}
  """
  @spec exchange(Account.t(), Money.t(), Currency.t()) :: Account.t()
  def exchange(account, to_exchange, new_currency) do
    with base_money <- Wallet.get_money(account.wallet, to_exchange.currency),
         {:ok, _} <- Money.has_enough(base_money, to_exchange),
         after_send <- Money.decrease(base_money, to_exchange),
         to_receive <- Money.convert(to_exchange, new_currency) do
      account
      |> Account.put_money(after_send)
      |> Account.put_money(to_receive)
    end
  end

  @doc """
  Does multiple checks on a list of {receiver, pct}

  Throws an error if split doesn't sum 100% over recipients

  ## Examples
    iex> valid_split([{%Account{..}, 110}])
    {:error, "Invalid split!"}

    iex> valid_split([{%Account{..}, 20}, {%Account{..}, 30}])
    {:error, "Invalid split!"}

    iex> valid_split([{%Account{..}, 66}, {%Account{..}, 34}])
    {:ok, {%Account{..}, 66}, {%Account{..}, 34}}
    
  """
  @spec valid_split([{Account.t(), number()}]) ::
          {:ok, [{Account.t(), number()}]} | {:error, String.t()}
  def valid_split(receivers) do
    pct_sum =
      receivers
      |> Enum.map(fn t -> elem(t, 1) end)
      |> Enum.sum()

    if pct_sum == 100 do
      {:ok, receivers}
    else
      {:error, "Invalid split!"}
    end
  end
end
