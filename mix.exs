defmodule Mix.Tasks.Compile.Src do
  def run(_) do
    priv_dir = :code.priv_dir(:exfswatch)
    case :os.type() do
      {:unix, :darwin} ->
        Mix.shell.cmd("clang -framework CoreFoundation -framework CoreServices -Wno-deprecated-declarations c_src/mac/*.c -o #{priv_dir}/mac_listener")
      {:unix, :freebsd} ->
        Mix.shell.cmd("cc c_src/bsd/*.c -o #{priv_dir}/kqueue")
      _ -> nil
    end
  end
end

defmodule ExFSWatch.Mixfile do
  use Mix.Project

  def project do
    [ app: :exfswatch,
      version: "0.4.0",
      elixir: "~> 1.0",
      compilers: [ :src, :elixir, :app ],
      deps: deps(),
      description: "A file change watcher wrapper based on [fs](https://github.com/synrc/fs)",
      source_url: "https://github.com/falood/exfswatch",
      package: package(),
      docs: [
        extras: ["README.md"],
        main: "readme",
      ]
    ]
  end

  def application do
    [ mod: { ExFSWatch, [] },
      included_applications: [:logger],
    ]
  end

  defp deps do
    [ { :ex_doc, "~> 0.14", only: :docs },
    ]
  end

  defp package do
    %{ maintainers: ["Xiangrong Hao"],
       files: ["priv", "lib", "c_src", "README.md", "mix.exs"],
       licenses: ["WTFPL"],
       links: %{"Github" => "https://github.com/falood/exfswatch"}
     }
  end
end
