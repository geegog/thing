defmodule Thing do


  alias :mnesia, as: Mnesia
  @node_list [node()]

  def init() do
    case Mnesia.create_schema(@node_list) do
      :ok -> case Mnesia.start() do
        :ok -> case Mnesia.create_table(:thing, [attributes: [:id, :value], type: :set]) do
          {:atomic, :ok} -> {:ok, table: :thing}
          error -> {:error, error}
        end
        {:error, error} -> error
      end
      {:error, error} -> error
    end
  end

  def cleanup() do
    Mnesia.stop()
    Mnesia.delete_schema(@node_list)
  end

  def create(value) do
    init()
    random_number = Enum.random(0..100)
    data_to_write = fn -> Mnesia.write({:thing, random_number, value}) end
    save(data_to_write)
  end

  def create(id, value) when id > 0 do
    case find(id) do
      nil -> data_to_write = fn -> Mnesia.write({:thing, id, value}) end
        save(data_to_write)
      _ -> {:error}
    end
  end

  def create(id, _value) when id <= 0 do
    {:error}
  end

  defp save(data_to_write) do
    case Mnesia.transaction(data_to_write) do
      {:atomic, :ok} -> {:atomic, :ok}
      error -> error
    end
  end

  def find(id) do
    data_to_read = fn -> Mnesia.read({:thing, id}) end
    case Mnesia.transaction(data_to_read) do
      {:atomic, [data]} -> data
      {:atomic, []} -> nil
    end
  end
end
