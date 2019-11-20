defmodule MoneyTest do
  use ExUnit.Case, async: true
  alias FinancialSystem.Money

  test "new/2 with correct parameters creates a money struct" do
    assert %Money{currency: :BRL, amount: 100} = Money.new(:BRL, 100)
  end

  test "new/2 with an invalid currency throws error" do
    assert {:error, _} = Money.new(:AHMEDALQ, 100)
  end

  test "new/2 with a negative amount throws error" do
    assert {:error, _} = Money.new(:BRL, -100)
  end

  test "increase/2 with valid params increases a money amount" do
    m1 = Money.new(:BRL, 100)
    m2 = Money.new(:BRL, 200)
    assert %Money{currency: :BRL, amount: 300} == Money.increase(m1, m2)
  end

  test "increase/2 throws an error when trying to sum different currencies" do
    m1 = Money.new(:BRL, 100)
    m2 = Money.new(:USD, 200)
    assert {:error, _} = Money.increase(m1, m2)
  end

  test "decrease/2 with valid params decreases a money amount" do
    m1 = Money.new(:BRL, 300)
    m2 = Money.new(:BRL, 200)
    assert %Money{currency: :BRL, amount: 100} == Money.decrease(m1, m2)
  end

  test "decrease/2 throws an error when trying on different currencies" do
    m1 = Money.new(:BRL, 300)
    m2 = Money.new(:USD, 200)
    assert {:error, _} = Money.decrease(m1, m2)
  end

  test "decrease/2 throws an error when result will be a negative value" do
    m1 = Money.new(:BRL, 300)
    m2 = Money.new(:BRL, 500)
    assert {:error, _} = Money.decrease(m1, m2)
  end

  test "same_currency?/2 throws error on different currencies" do
    m1 = Money.new(:BRL, 300)
    m2 = Money.new(:USD, 300)
    {:error, _} = Money.same_currency?(m1, m2)
  end

  test "same_currency?/2 returns {:ok, currency} when same currency" do
    m1 = Money.new(:BRL, 300)
    m2 = Money.new(:BRL, 300)
    {:ok, :BRL} = Money.same_currency?(m1, m2)
  end

  test "possible_amount?/1 returns error when value is not an integer" do
    value = 302.5
    assert {:error, _} = Money.possible_amount?(value)
  end

  test "possible_amount?/1 returns error when value is negative" do
    value = -300
    assert {:error, _} = Money.possible_amount?(value)
  end

  test "possible_amount?/1 returns {:ok, value} when value is correct" do
    value = 300
    assert {:ok, 300} = Money.possible_amount?(value)
  end
end
