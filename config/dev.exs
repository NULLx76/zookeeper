# Set peerage to static for development
config :peerage,
  via: Peerage.Via.List,
  node_list: [:"zookeeper@127.0.0.1"],
  log_results: false
