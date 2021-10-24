defmodule Zookeeper do
  alias Zookeeper.Twitter

  def get_pic do
    token = Application.fetch_env!(:zookeeper, :twitter_token)
    id = Twitter.TweetStore.get_random()
    Twitter.get_tweet_with_image(token, id) |> IO.inspect()
  end
end
