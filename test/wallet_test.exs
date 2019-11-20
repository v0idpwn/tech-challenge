defmodule WalletTest do
  use ExUnit.Case
  alias FinancialSystem.Wallet
  alias FinancialSystem.Money

  test "unify/1 correctly unifies repeated money structs" do
    m1 = Money.new(:BRL, 100)
    m2 = Money.new(:USD, 50)
    m3 = Money.new(:BRL, 125)
    mlist = [m1, m2, m3]
    assert %Money{currency: :BRL, amount: 225} = Wallet.unify(mlist, :BRL)
  end

  test "unify/1 returns nil when doesn't find a currency" do
    m1 = Money.new(:BRL, 100)
    m2 = Money.new(:USD, 50)
    m3 = Money.new(:BRL, 125)
    mlist = [m1, m2, m3]

    assert nil == Wallet.unify(mlist, :EUR)
  end

  test "new/1 returns a nil filtered & unified list" do
    m1 = Money.new(:BRL, 100)
    m2 = Money.new(:USD, 50) 
    m3 = Money.new(:BRL, 125)
    mlist = [m1, m2, m3]

    assert [%Money{currency: :BRL, amount: 225}, m2] = Wallet.new(mlist)
  end

  test "update/2 returns a wallet with the correct values" do
    m1 = Money.new(:BRL, 100)
    m2 = Money.new(:USD, 20) 
    wallet = Wallet.new([m1, m2])
    assert [%Money{currency: :BRL, amount: 100}, 
            %Money{currency: :USD, amount: 20}] = wallet

    updated_wallet = Wallet.update(wallet, Money.new(:BRL, 50))

    assert [%Money{currency: :BRL, amount: 50}, %Money{currency: :USD, amount: 20}] = updated_wallet
  end

  test "get_money/2 returns correct money" do
    m1 = Money.new(:BRL, 100)
    m2 = Money.new(:USD, 20) 
    wallet = Wallet.new([m1, m2])

    assert Wallet.get_money(wallet, :BRL) == m1
  end

  test "get_money/2 returns nil if doesn't exist" do
    m1 = Money.new(:BRL, 100)
    m2 = Money.new(:USD, 20) 
    wallet = Wallet.new([m1, m2])

    assert Wallet.get_money(wallet, :EUR) == nil
  end
end
