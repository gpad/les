# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :les,
  ecto_repos: [Les.Repo]

# Configures the endpoint
config :les, LesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HG2dpygLbpXhCipA2FTSd3t2TyUedC17VYHXvPKfd5wwD53sVE77r8HIB/l51+Fe",
  render_errors: [view: LesWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Les.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :lager,
  colored: true,
  error_logger_hwm: 5000

config :sasl,
  errlog_type: :error

config :riak_core,
  ring_state_dir: 'data/ring_data_dir',
  handoff_port: 8099,
  handoff_ip: '127.0.0.1',
  schema_dirs: ['priv'],
  ring_creation_size: 16,
  vnode_inactivity_timeout: 10000

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
