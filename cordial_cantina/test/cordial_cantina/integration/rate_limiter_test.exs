defmodule CordialCantina.Integration.RateLimiterTest do
  use ExUnit.Case, async: true

  alias CordialCantina.Integration.RateLimiter

  describe "acquire/1" do
    test "first request is immediate" do
      {:ok, limiter} = RateLimiter.start_link(name: :test_limiter_1, interval_ms: 100)

      start = System.monotonic_time(:millisecond)
      :ok = RateLimiter.acquire(limiter)
      elapsed = System.monotonic_time(:millisecond) - start

      # First request should be immediate (< 10ms)
      assert elapsed < 10

      GenServer.stop(limiter)
    end

    test "subsequent requests are rate limited" do
      {:ok, limiter} = RateLimiter.start_link(name: :test_limiter_2, interval_ms: 50)

      # First request
      :ok = RateLimiter.acquire(limiter)

      # Second request should wait
      start = System.monotonic_time(:millisecond)
      :ok = RateLimiter.acquire(limiter)
      elapsed = System.monotonic_time(:millisecond) - start

      # Should have waited approximately 50ms
      assert elapsed >= 45

      GenServer.stop(limiter)
    end

    test "acquire with timeout returns error on timeout" do
      {:ok, limiter} = RateLimiter.start_link(name: :test_limiter_3, interval_ms: 500)

      # First request
      :ok = RateLimiter.acquire(limiter)

      # Second request with short timeout should fail
      result = RateLimiter.acquire(limiter, 10)
      assert {:error, :timeout} = result

      GenServer.stop(limiter)
    end
  end

  describe "endpoint rotation" do
    test "register_endpoint adds endpoints" do
      {:ok, limiter} = RateLimiter.start_link(name: :test_limiter_4, interval_ms: 10)

      :ok = RateLimiter.register_endpoint(limiter, :endpoint_a)
      :ok = RateLimiter.register_endpoint(limiter, :endpoint_b)
      :ok = RateLimiter.register_endpoint(limiter, :endpoint_c)

      status = RateLimiter.status(limiter)
      assert status.endpoints == [:endpoint_a, :endpoint_b, :endpoint_c]

      GenServer.stop(limiter)
    end

    test "next_endpoint returns endpoints in round-robin order" do
      {:ok, limiter} = RateLimiter.start_link(name: :test_limiter_5, interval_ms: 10)

      :ok = RateLimiter.register_endpoint(limiter, :a)
      :ok = RateLimiter.register_endpoint(limiter, :b)
      :ok = RateLimiter.register_endpoint(limiter, :c)

      # Should cycle through A, B, C, A, B, C...
      assert {:ok, :a} = RateLimiter.next_endpoint(limiter)
      assert {:ok, :b} = RateLimiter.next_endpoint(limiter)
      assert {:ok, :c} = RateLimiter.next_endpoint(limiter)
      assert {:ok, :a} = RateLimiter.next_endpoint(limiter)
      assert {:ok, :b} = RateLimiter.next_endpoint(limiter)

      GenServer.stop(limiter)
    end

    test "next_endpoint returns error when no endpoints registered" do
      {:ok, limiter} = RateLimiter.start_link(name: :test_limiter_6, interval_ms: 10)

      assert {:error, :no_endpoints} = RateLimiter.next_endpoint(limiter)

      GenServer.stop(limiter)
    end

    test "next_endpoint respects rate limit" do
      {:ok, limiter} = RateLimiter.start_link(name: :test_limiter_7, interval_ms: 50)

      :ok = RateLimiter.register_endpoint(limiter, :a)
      :ok = RateLimiter.register_endpoint(limiter, :b)

      # First call is immediate
      {:ok, :a} = RateLimiter.next_endpoint(limiter)

      # Second call should wait
      start = System.monotonic_time(:millisecond)
      {:ok, :b} = RateLimiter.next_endpoint(limiter)
      elapsed = System.monotonic_time(:millisecond) - start

      assert elapsed >= 45

      GenServer.stop(limiter)
    end
  end

  describe "status/1" do
    test "returns current state" do
      {:ok, limiter} = RateLimiter.start_link(name: :test_limiter_8, interval_ms: 100)

      :ok = RateLimiter.register_endpoint(limiter, :test)
      :ok = RateLimiter.acquire(limiter)

      status = RateLimiter.status(limiter)

      assert status.interval_ms == 100
      assert status.endpoints == [:test]
      assert status.current_index == 0
      assert is_integer(status.last_request_ms_ago) or is_nil(status.last_request_ms_ago)

      GenServer.stop(limiter)
    end
  end
end
