# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :email_test, EmailTest.Mailer,
  adapter: Bamboo.MandrillAdapter,
  api_key: 'lolz'
