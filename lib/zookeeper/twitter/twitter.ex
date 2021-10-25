defmodule Zookeeper.Twitter do
  @root "https://api.twitter.com/2"

  @spec lookup_twitter_ids!(binary, [binary]) :: [map]
  def lookup_twitter_ids!(token, accounts) do
    joined = Enum.join(accounts, ",")

    {:ok, resp} =
      Finch.build(:get, "#{@root}/users/by?usernames=#{joined}", [
        {"Authorization", "Bearer " <> token}
      ])
      |> Finch.request(MyFinch)

    Poison.decode!(resp.body)
    |> Map.fetch!("data")
  end

  defp do_call!(token, url) do
    {:ok, resp} =
      Finch.build(:get, url, [{"Authorization", "Bearer " <> token}])
      |> Finch.request(MyFinch)

    Poison.decode!(resp.body)
  end

  defp reduce_tweets(body) do
    Enum.reduce(body["data"], [], fn %{"id" => id}, acc -> [id | acc] end)
  end

  defp build_fetch_tweets_url(user_id, page \\ nil)

  defp build_fetch_tweets_url(user_id, nil),
    do: "#{@root}/users/#{user_id}/tweets?exclude=retweets&max_results=100"

  defp build_fetch_tweets_url(user_id, page),
    do:
      "#{@root}/users/#{user_id}/tweets?exclude=retweets&max_results=100&pagination_token=#{page}"

  defp fetch_tweets!(_, _, nil, accum), do: accum

  defp fetch_tweets!(token, user_id, pagination, accum) do
    body = do_call!(token, build_fetch_tweets_url(user_id, pagination))
    accum = accum ++ reduce_tweets(body)
    fetch_tweets!(token, user_id, Map.get(body["meta"], "next_token"), accum)
  end

  def retrieve_all_tweet_ids!(token, user_id) do
    body = do_call!(token, build_fetch_tweets_url(user_id))
    fetch_tweets!(token, user_id, Map.get(body["meta"], "next_token"), reduce_tweets(body))
  end

  def get_tweet_with_image(token, id) do
    url =
      "#{@root}/tweets/#{id}?expansions=attachments.media_keys&media.fields=url,preview_image_url"

    with {:ok, resp} <-
           Finch.build(:get, url, [
             {"Authorization", "Bearer " <> token}
           ])
           |> Finch.request(MyFinch),
         {:ok, body} <- Poison.decode(resp.body),
         {:ok, url} <- get_in(body, ["includes", "media"]) |> hd |> Map.fetch("url") do
      {:ok,
       %{
         :id => id,
         :media_preview_url => url
       }}
    else
      {:error, e} -> {:error, e}
      :error -> {:error, "invalid json"}
    end
  end
end
