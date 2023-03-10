import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :taste_buddy, TasteBuddyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "HMpE/F+Ms+fffpts3frV/VwCaqn9e7qbLfCeMycp3fX7otwniTVQ+Ha4YlOjDca/",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
