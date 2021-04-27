defmodule ThingTest do
  use ExUnit.Case
  doctest Thing

  setup_all do
    Thing.init()
    on_exit(fn -> Thing.clean_up() end)
  end

  test "adds a new record" do
    id = UUID.uuid4()
    assert Thing.create(id, "the new record's value") == {:atomic, :ok}
  end

  test "id is not a valid uuid" do
    assert Thing.create(12345, "value") == {:error}
  end

  test "no match" do
    assert Thing.find(UUID.uuid4()) == nil
  end

  test "id already exists" do
    id = UUID.uuid4()
    Thing.create(id, "the new record's value")
    assert Thing.create(id, "value") == {:error}
  end

  test "creates a new record with a newly generated" do
    assert Thing.create("this 'thing' value") == {:atomic, :ok}
  end

end
