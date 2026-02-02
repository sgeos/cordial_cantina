defmodule CordialCantina.Nif do
  @moduledoc """
  NIF bindings for Cordial Cantina.

  This module provides Erlang NIF bindings to Rust functions from the joltshark
  library. The NIF is compiled via Rustler during mix compile.
  """

  use Rustler,
    otp_app: :cordial_cantina,
    crate: "nif"

  @doc """
  A no-operation function used to verify NIF loading.

  Returns :ok if the NIF is loaded successfully.

  ## Examples

      iex> CordialCantina.Nif.nop()
      :ok
  """
  def nop, do: :erlang.nif_error(:nif_not_loaded)
end
