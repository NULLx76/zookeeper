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

    Map.fetch!(Poison.decode!(resp.body), "data")
  end

  def retrieve_all_tweet_ids(token, id, max_results \\ 100, pagination \\ nil, accum \\ []) do
    url = "#{@root}/users/#{id}/tweets?exclude=retweets&max_results=#{max_results}"
    url = if is_binary(pagination), do: url <> "&pagination_token=" <> pagination, else: url

    with {:ok, resp} <-
           Finch.build(:get, url, [
             {"Authorization", "Bearer " <> token}
           ])
           |> Finch.request(MyFinch),
         {:ok, body} <- Poison.decode(resp.body) do
      ids =
        body["data"]
        |> Enum.reduce([], fn %{"id" => id}, acc -> [id | acc] end)

      case Map.fetch(body["meta"], "next_token") do
        {:ok, next_token} ->
          retrieve_all_tweet_ids(token, id, max_results, next_token, ids ++ accum)

        :error ->
          {:ok, ids ++ accum}
      end
    else
      {:error, exception} -> {:error, exception}
    end
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
