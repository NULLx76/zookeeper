defmodule Zookeeper.Twitter.TweetStore do
  use GenServer

  @table :tweet_store

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    :ets.new(@table, [:set, :private, :named_table])
    {:ok, 0}
  end

  def get_random do
    GenServer.call(__MODULE__, :get_random)
  end

  def put(ids) do
    GenServer.cast(__MODULE__, {:put, ids})
    ids
  end

  def clear do
    GenServer.cast(__MODULE__, :clear)
  end

  ### internal api
  def handle_call(:get_random, _from, state) do
    case :ets.lookup(@table, Enum.random(1..state)) do
      [{_, id}] -> {:reply, id, state}
      _ -> {:reply, nil, state}
    end
  end

  def handle_cast({:put, ids}, state) when is_list(ids) do
    state = state + 1

    entries =
      Enum.with_index(ids, state)
      |> Enum.map(fn {a, b} -> {b, a} end)

    :ets.insert(@table, entries)

    state = state + length(entries) - 1
    {:noreply, state}
  end

  def handle_cast({:put, id}, state) do
    state = state + 1
    :ets.insert(@table, {state, id})
    {:noreply, state}
  end

  def handle_cast(:clear, _) do
    :ets.delete_all_objects(@table)
    {:noreply, 0}
  end
end
