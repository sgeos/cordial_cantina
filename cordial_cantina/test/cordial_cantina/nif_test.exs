defmodule CordialCantina.NifTest do
  use ExUnit.Case, async: true

  describe "nop/0" do
    test "returns :ok when NIF is loaded" do
      assert CordialCantina.Nif.nop() == :ok
    end
  end
end
