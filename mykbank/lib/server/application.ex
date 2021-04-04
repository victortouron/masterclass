defmodule Mykbank.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    IO.puts "Mix App Starting"
    children = [
      # Starts a worker by calling: Mixproject.Worker.start_link(arg)
      # {Mixproject.Worker, arg}
      Bank.Supervisor,
      {Plug.Cowboy, scheme: :http, plug: Server.Router, options: [port: 4001]}
    ]
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [
      strategy: :one_for_one,
      name: Bank.Supervisor
    ]
    Supervisor.start_link(children, opts)
  end
end
