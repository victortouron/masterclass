defmodule Bank.Server do
  use GenServer

  def create(database, content) do
    account = Enum.random(0..9999999999999)
    GenServer.cast(Bank.Server, {:create, database, content, account})
    {:ok, account}
  end
  def add(database, {account, value}), do: GenServer.cast(Bank.Server, {:add, database, {account, value}})
  def retrieve(database, {account, value}), do: GenServer.cast(Bank.Server, {:retrieve, database, {account, value}})
  def read(database, account), do: GenServer.call(Bank.Server, {:read, database, account})

  def update_date_time(content) do
    {:ok, Map.put(content, 'update', DateTime.to_string(DateTime.utc_now()))}
  end

  def handle_cast({:create, database, content, account}, intern_state) do
    {:ok, updated_content} = update_date_time(content)
    final_content = Map.put(updated_content, 'amount', 0)
    :ets.insert_new(database, {account, final_content})
    {:noreply, intern_state}
  end
  def handle_cast({:add, database, {account, value}}, intern_state) do
    [{_resp, map}] = :ets.lookup(database, account)
    {:ok, updated_map} = update_date_time(map)
    {:ok, amount} = Map.fetch(updated_map, 'amount')
    final_map = Map.put(updated_map, 'amount', amount + value)
    :ets.insert(database, {account, final_map})
    {:noreply, intern_state}
  end
  def handle_cast({:retrieve, database, {account, value}}, intern_state) do
    [{_resp, map}] = :ets.lookup(database, account)
    {:ok, updated_map} = update_date_time(map)
    {:ok, amount} = Map.fetch(updated_map, 'amount')
    final_map = Map.put(updated_map, 'amount', amount - value)
    :ets.insert(database, {account, final_map})
    {:noreply, intern_state}
  end
  def handle_call({:read, database, account}, _pid, intern_state) do
    {:reply, :ets.lookup(database, account), intern_state}
  end

  def start_link(initial_value) do
    IO.puts "Bank Server Start Link"
    {:ok, _pid} = GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end
  def init(_) do
    {:ok, :ok}
  end
end
