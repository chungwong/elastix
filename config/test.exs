import Config

config :elastix,
  test_url: "https://127.0.0.1:9200",
  shield: true,
  username: "elastic",
  password: "elastic",
  httpoison_options: [
    ssl: [verify: :verify_none, log_level: :error]
  ],
  test_index: "elastix_test_index",
  test_index_2: "elastix_test_index_2"
