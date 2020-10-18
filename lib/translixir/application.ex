defmodule Translixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Translixir.Worker.start_link(arg)
      # {Translixir.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Translixir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
# def init() do
#   # put = action(:put, "{ :crux.db/id :jorge-3, :first-name \"Michael\", :last-name \"Jorge\", }")
#   client =  Client.new("localhost", "3000")

#   client
#   |> entity_tx(":jorge-3")
#   |> IO.inspect
# end
