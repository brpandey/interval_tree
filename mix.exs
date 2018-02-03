defmodule IntervalTree.Mixfile do
  use Mix.Project

  def project do
    [
      app: :interval_tree,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp description() do
    """
    Implements an interval tree using an augmented self-balancing AVL tree
    with an interval as the data field and a max value tracking the 
    interval high value in the subtree rooted at that node
    """
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Bibek Pandey"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/brpandey/interval_tree",
        "Docs" => "https://hexdocs.pm/interval_tree/"
      }
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ex_doc, "~> 0.18.1", only: :dev}]
  end
end
