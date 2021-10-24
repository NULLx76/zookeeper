defmodule Zookeeper.Twitter.TweetFetcher do
  use Task, restart: :transient
  alias Zookeeper.Twitter
  alias Zookeeper.Twitter.TweetStore

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [
      Keyword.fetch!(arg, :token),
      Keyword.fetch!(arg, :accounts)
    ])
  end

  def run(token, accounts) do
    for account <- Twitter.lookup_twitter_ids!(token, accounts) do
      Task.Supervisor.start_child(
        Zookeeper.TaskSupervisor,
        __MODULE__,
        :populate,
        [token, account],
        restart: :transient
      )
    end
  end

  def populate(token, account) do
    {:ok, list} = Twitter.retrieve_all_tweet_ids(token, account["id"])
    TweetStore.put(list)

    IO.puts("Populated TweetStore for #{account["name"]}")
  end
end
