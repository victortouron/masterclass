defmodule MykbankTest do
  use ExUnit.Case
  doctest Mykbank

  test "greets the world" do
    assert Mykbank.hello() == :world
  end
end
