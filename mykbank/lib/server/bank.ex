defmodule Bank.Server do
  use GenServer

  def create(database, content) do
    account = Enum.random(0..9999999999999)
    GenServer.cast(Bank.Server, {:create, database, content, account})
    {:ok, account}
  end
  def update(database, {account, key, value}), do: GenServer.cast(Bank.Server, {:update, database, {account, key, value}})
  def delete(database, account), do: GenServer.cast(Bank.Server, {:delete, database, account})
  def add(database, {account, value}), do: GenServer.cast(Bank.Server, {:add, database, {account, value}})
  def retrieve(database, {account, value}), do: GenServer.cast(Bank.Server, {:retrieve, database, {account, value}})
  def read(database, account), do: GenServer.call(Bank.Server, {:read, database, account})
  def get_table(), do: GenServer.call(__MODULE__, :get_table)

  def update_date_time(content) do
    {:ok, Map.put(content, 'update', DateTime.to_string(DateTime.utc_now()))}
  end

  def handle_cast({:create, database, content, account}, intern_state) do
    {:ok, updated_content} = update_date_time(content)
    amount_content = Map.put(updated_content, 'amount', 0)
    final_content = Map.put(amount_content, 'account', account)
    :ets.insert_new(database, {account, final_content})
    {:noreply, intern_state}
  end
  def handle_cast({:update, database, {account, key, value}}, intern_state) do
    [{_resp, map}] = :ets.lookup(database, String.to_integer(account))
    {:ok, updated_map} = update_date_time(map)
    case key do
      "firstname" ->
        {:ok, firstname} = Map.fetch(updated_map, 'firstname')
        final_map = Map.put(updated_map, 'firstname', value)
        :ets.insert(database, {String.to_integer(account), final_map})
        "lastname" ->
          {:ok, lastname} = Map.fetch(updated_map, 'lastname')
          final_map = Map.put(updated_map, 'lastname', value)
          :ets.insert(database, {String.to_integer(account), final_map})
          "amount" ->
            {:ok, amount} = Map.fetch(updated_map, 'amount')
            final_map = Map.put(updated_map, 'amount', value)
            :ets.insert(database, {String.to_integer(account), final_map})
          end
    {:noreply, intern_state}
  end
  def handle_cast({:delete, database, account}, intern_state) do
    :ets.delete(database, String.to_integer(account))
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
  def handle_call(:get_table, _form, intern_state) do
     {:reply, :ets.tab2list(:bank), intern_state}
   end

  def start_link(initial_value) do
    IO.puts "Bank Server Start Link"
    {:ok, _pid} = GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end
  def init(_) do
    {:ok, :ok}
  end
end
