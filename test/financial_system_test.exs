defmodule FinancialSystemTest do
  use ExUnit.Case

  alias FinancialSystem.Money
  alias FinancialSystem.Account
  alias FinancialSystem.Wallet

  test "User should be able to transfer money to another account" do
    sender = Account.new("Ricardo Milos", [Money.new(:BRL, 450)])
    receiver = Account.new("Álvares de Azevedo", [])
    transfer = Money.new(:BRL, 150)

    result = FinancialSystem.transfer(sender, receiver, transfer)
    assert Wallet.get_money(result.sender.wallet, :BRL) == Money.new(:BRL, 300)
    assert Wallet.get_money(result.receiver.wallet, :BRL) == Money.new(:BRL, 150)
  end

  test "User cannot transfer if not enough money available on the account" do
    sender = Account.new("Jorge Amado", [Money.new(:BRL, 450)])
    receiver = Account.new("Otto Maria Carpeaux", [])
    transfer = Money.new(:BRL, 1000)

    assert {:error, _} = FinancialSystem.transfer(sender, receiver, transfer)
  end

  test "Cannot transfer when has no money of the currency in the account" do
    sender = Account.new("Jorge Amado", [Money.new(:BRL, 450)])
    receiver = Account.new("Otto Maria Carpeaux", [])
    transfer = Money.new(:USD, 1000)

    assert {:error, _} = FinancialSystem.transfer(sender, receiver, transfer)
  end

  test "A transfer should be cancelled if an error occurs" do
    # there are no side effects so no need to cancel
    # the function just fails
  end

  test "A transfer can be splitted between 2 or more accounts" do
    sender = Account.new("Graciliano Ramos", [Money.new(:BRL, 20000)])
    transferred = Money.new(:BRL, 5000)
    receivers = [
      {Account.new("Ivo Robotnik", []), 10},
      {Account.new("Aline Werner", [Money.new(:BRL, 500)]), 90}
    ]

    assert result = FinancialSystem.split_transfer(sender, receivers, transferred)
    assert Wallet.get_money(result.sender.wallet, :BRL) == Money.new(:BRL, 15000)
    assert Wallet.get_money(Map.fetch!(Enum.at(result.receivers, 0), :wallet), :BRL) == Money.new(:BRL, 500)
    assert Wallet.get_money(Map.fetch!(Enum.at(result.receivers, 1), :wallet), :BRL) == Money.new(:BRL, 5000)
  end

  test "Return error when trying invalid split" do
    sender = Account.new("Graciliano Ramos", [Money.new(:BRL, 20000)])
    transferred = Money.new(:BRL, 5000)
    receivers = [
      {Account.new("Ivo Robotnik", []), 10},
      {Account.new("Aline Werner", [Money.new(:BRL, 500)]), 190}
    ]

    assert {:error, _} = FinancialSystem.split_transfer(sender, receivers, transferred)

    sender = Account.new("Graciliano Ramos", [Money.new(:BRL, 200)])
    transferred = Money.new(:BRL, 5000)
    receivers = [
      {Account.new("Ivo Robotnik", []), 10},
      {Account.new("Aline Werner", [Money.new(:BRL, 500)]), 10}
    ]

    assert {:error, _} = FinancialSystem.split_transfer(sender, receivers, transferred)
  end

  test "Return error when not enough money for split" do
    sender = Account.new("Graciliano Ramos", [Money.new(:BRL, 2)])
    transferred = Money.new(:BRL, 5000)
    receivers = [
      {Account.new("Ivo Robotnik", []), 10},
      {Account.new("Aline Werner", [Money.new(:BRL, 500)]), 90}
    ]

    assert {:error, _} = FinancialSystem.split_transfer(sender, receivers, transferred)
  end

  test "User should be able to exchange money between different currencies" do
    acc = Account.new("Jorge Amado", [Money.new(:BRL, 2000)])
    to_exchange = Money.new(:BRL, 800)

    result = FinancialSystem.exchange(acc, to_exchange, :USD)

    assert Wallet.get_money(result.wallet, :BRL) == Money.new(:BRL, 1200)
    assert Wallet.get_money(result.wallet, :USD) == Money.new(:USD, 800)
  end

  @tag :skip
  test "Currencies should be in compliance with ISO 4217" do
    # check out currency_test.exs
  end
end
