defmodule ExFSWatch.Mixfile do
  use Mix.Project

  def project do
    [ app: :exfswatch,
      version: "0.0.3",
      elixir: "~> 1.0",
      deps: deps,
      description: "A file change watcher wrapper based on [fs](https://github.com/synrc/fs)",
      source_url: "https://github.com/falood/exfswatch",
      package: package,
    ]
  end

  def application do
    [ mod: { ExFSWatch, [] },
      applications: [:logger]
    ]
  end

  defp deps do
    [ {:fs, "~> 0.9.1"} ]
  end

  defp package do
    %{ licenses: ["BSD 3-Clause"],
       links: %{"Github" => "https://github.com/falood/exfswatch"}
     }
  end
end
