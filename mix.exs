defmodule FileSystem.Mixfile do
  use Mix.Project

  def project do
    [ app: :file_system,
      version: "0.1.0",
      elixir: "~> 1.5-rc",
      compilers: [ :elixir, :app ],
      deps: deps(),
      description: "A file system change watcher wrapper based on [fs](https://github.com/synrc/fs)",
      source_url: "https://github.com/falood/file_system",
      package: package(),
      docs: [
        extras: ["README.md"],
        main: "readme",
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
    ]
  end

  defp deps do
    [
      { :ex_doc, "~> 0.14", only: :docs },
    ]
  end

  defp package do
    %{ maintainers: ["Xiangrong Hao", "Max Veytsman"],
       files: [
         "lib", "README.md", "mix.exs",
         "c_src/bsd/main.c",
         "c_src/mac/cli.c",
         "c_src/mac/cli.h",
         "c_src/mac/common.h",
         "c_src/mac/compat.c",
         "c_src/mac/compat.h",
         "c_src/mac/main.c",
         "priv/inotifywait.exe",
       ],
       licenses: ["WTFPL"],
       links: %{"Github" => "https://github.com/falood/file_system"}
     }
  end
end
