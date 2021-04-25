defmodule ThingTest do
  use ExUnit.Case
  doctest Thing

  setup_all do
    Thing.init()
    on_exit(fn -> Thing.cleanup() end)
  end

  test "adds a new record" do
    assert Thing.create(101, "the new record's value") == {:atomic, :ok}
  end

  test "id is not a positive integer" do
    assert Thing.create(-1, "value") == {:error}
  end

  test "no match" do
    assert Thing.find(104) == nil
  end

  test "id already exists" do
    id = 102
    Thing.create(id, "the new record's value")
    assert Thing.create(id, "value") == {:error}
  end

  test "creates a new record with a newly generated" do
    assert Thing.create("this 'thing' value") == {:atomic, :ok}
  end

end
