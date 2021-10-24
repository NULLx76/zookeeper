defmodule ZookeeperTest.TweetStoreTest do
  use ExUnit.Case
  alias Zookeeper.Twitter.TweetStore

  setup do
    on_exit(&TweetStore.clear/0)
  end

  test "insert one id" do
    TweetStore.put("5")
    assert TweetStore.get_random() == "5"
  end

  test "insert multiple ids indiv" do
    TweetStore.put("5")
    TweetStore.put("12")
    assert TweetStore.get_random() in ["5", "12"]
    assert TweetStore.get_random() in ["5", "12"]
    assert TweetStore.get_random() in ["5", "12"]
  end

  test "insert multiple ids together" do
    TweetStore.put(["5", "12"])
    assert TweetStore.get_random() in ["5", "12"]
    assert TweetStore.get_random() in ["5", "12"]
    assert TweetStore.get_random() in ["5", "12"]

    TweetStore.put(["7", "8"])
    assert TweetStore.get_random() in ["5", "12", "7", "8"]
    assert TweetStore.get_random() in ["5", "12", "7", "8"]
    assert TweetStore.get_random() in ["5", "12", "7", "8"]
  end
end
