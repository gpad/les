use Mix.Config

config :riak_core,
  node: 'gpad_3@127.0.0.1',
  web_port: 8398,
  handoff_port: 8399,
  ring_state_dir: 'ring_data_dir_3',
  platform_data_dir: 'data_3'

import_config "dev.exs"
