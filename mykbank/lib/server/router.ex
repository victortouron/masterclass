defmodule Server.Router do
  import Plug.BasicAuth
  use Plug.Router

  plug Plug.Static, from: "lib/priv/static/", at: "/static"
  plug :basic_auth, username: "hello", password: "secret"
  plug :match
  plug :dispatch

  get "/all" do
    json = Poison.encode!(Enum.map(Bank.Server.get_table(), fn {_key, map} -> map end))
    send_resp(conn, 200, json)
  end

  get "/edit" do
    %{"account" => account, "key"=> key, "value" => value} = Plug.Conn.Query.decode(conn.query_string)
    res = Bank.Server.update(:bank, {account, key, value})
    json = Poison.encode!(res)
    send_resp(conn, 200, json)
  end


  get "/add" do
    %{"account" => account, "amount" => amount} = Plug.Conn.Query.decode(conn.query_string)
    res = Bank.Server.add(:bank, {String.to_integer(account), String.to_integer(amount)})
    json = Poison.encode!(res)
    send_resp(conn, 200, json)
  end

  get "/rem" do
    %{"account" => account, "amount" => amount} = Plug.Conn.Query.decode(conn.query_string)
    res = Bank.Server.retrieve(:bank, {String.to_integer(account), String.to_integer(amount)})
    json = Poison.encode!(res)
    send_resp(conn, 200, json)
  end

  get "/delete" do
    %{"account" => account} = Plug.Conn.Query.decode(conn.query_string)
    res = Bank.Server.delete(:bank, account)
    json = Poison.encode!(res)
    send_resp(conn, 200, json)
  end

  get "/retrieve" do
    %{"account" => account} = Plug.Conn.Query.decode(conn.query_string)
    [{resp, map}] = Bank.Server.read(:bank, String.to_integer(account))
    json = Poison.encode!(map)
    send_resp(conn, 200, json)
  end

  get _ do
    send_file(conn, 200, "lib/priv/static/index.html")
  end
  #
  # #
  # get "/test", do: send_file(conn, 200, "lib/priv/static/index.html")
  # match _, do: send_resp(conn, 401, "Page Not Found")
end
