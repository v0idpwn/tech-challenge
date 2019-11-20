defmodule CurrencyTest do
  use ExUnit.Case
  alias FinancialSystem.Money.Currency

  test "possible_currency?/1 returns {:ok, currency} if valid input" do
    assert {:ok, :BRL} = Currency.possible_currency?(:BRL)
  end

  test "possible_currency?/1 returns error tuple if invalid currency" do
    assert {:error, _} = Currency.possible_currency?("BRL")
    assert {:error, _} = Currency.possible_currency?(2)
    assert {:error, _} = Currency.possible_currency?(:foobar)
  end

  test "currency_details/1 returns currency data" do
    assert %{code: _, number: _, decimal_separator: _} = Currency.details(:USD)
    assert %{code: _, number: _, decimal_separator: _} = Currency.details(:EUR)
    assert %{code: _, number: _, decimal_separator: _} = Currency.details(:BRL)
  end

  test "currency_details/1 returns error when not a currency" do
    assert {:error, _} = Currency.details(:FOO)
  end


  test "get_currencies/0 returns currency list" do
    assert is_list(Currency.get_currencies())
  end
end
