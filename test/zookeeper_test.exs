defmodule ZookeeperTest do
  use ExUnit.Case
  doctest Zookeeper

  test "greets the world" do
    assert Zookeeper.hello() == :world
  end
end
