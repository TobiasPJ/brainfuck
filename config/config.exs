import Config

config :brainfuck, Brainfuck.Setting,
  saved_programs_path: "/saved_programs",
  settings: "/lib/brainfuck/user/settings.json"

import_config "#{config_env()}.exs"
