defmodule AccountTest do
  use ExUnit.Case
  alias FinancialSystem.Account
  alias FinancialSystem.Money

  test "new/1 with correct params creates an account" do
    m1 = Money.new(:BRL, 150)
    m2 = Money.new(:BRL, 150)
    m3 = Money.new(:USD, 20)
    assert account = Account.new("Keith Emerson", [m1, m2, m3])
    assert account.name == "Keith Emerson"
    assert account.wallet == [%Money{currency: :BRL, amount: 300}, m3]
  end

  test "new/1 with invalid name returns error" do
    assert {:error, _} = Account.new(3, [])
    assert {:error, _} = Account.new('keith emerson', []) #charlist
  end

  test "put_money/2 can add money in account" do
    account = 
      Account.new("Keith Emerson", [])
      |> Account.put_money(Money.new(:BRL, 150))

    assert Account.new("Keith Emerson", [Money.new(:BRL, 150)]) == account
  end

  test "put_money/2 can substitute money in account" do
    account = 
      Account.new("Keith Emerson", [Money.new(:BRL, 200)])
      |> Account.put_money(Money.new(:BRL, 150))
        
    assert Account.new("Keith Emerson", [Money.new(:BRL, 150)]) == account
  end

  test "put_money/2 can add moneys with new currencies" do
    account = 
      Account.new("Keith Emerson", [Money.new(:BRL, 200)])
      |> Account.put_money(Money.new(:USD, 150))
        
    # our wallet data structure doesn't worry with order so we have
    # to assert individually

    assert account.name == "Keith Emerson"
    assert Enum.member?(account.wallet, Money.new(:BRL, 200))
    assert Enum.member?(account.wallet, Money.new(:USD, 150))
  end
end
