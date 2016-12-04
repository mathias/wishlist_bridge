defmodule GoodreadsAmazonWishlistBridge.Mixfile do
  use Mix.Project

  def project do
    [app: :wishlist_bridge,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger,  :httpoison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:aws_auth, "~> 0.6.1"},
      {:dialyxir, "~> 0.4", only: [:dev]},
      {:dogma, "~> 0.1.13", only: [:dev]},
      {:httpoison, "~> 0.10.0"},
      {:sweet_xml, "~> 0.6.2"},
      {:timex, "~> 3.1"}
    ]
  end
end
