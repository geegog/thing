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

  def clean_up() do
    Mnesia.stop()
    Mnesia.delete_schema(@node_list)
  end

  def create(value) do
    record_to_write = fn -> Mnesia.write({:thing, UUID.uuid4(), value}) end
    save(record_to_write)
  end

  def create(id, value) do
    case UUID.info(id) do
      {:ok, _}  -> case find(id) do
        nil -> record_to_write = fn -> Mnesia.write({:thing, id, value}) end
          save(record_to_write)
        _ -> {:error}
      end
      {:error, _} -> {:error}
    end
  end

  defp save(record_to_write) do
    case Mnesia.transaction(record_to_write) do
      {:atomic, :ok} -> {:atomic, :ok}
      error -> error
    end
  end

  def find(id) do
    record_to_read = fn -> Mnesia.read({:thing, id}) end
    case Mnesia.transaction(record_to_read) do
      {:atomic, [record]} -> record
      {:atomic, []} -> nil
    end
  end
end
