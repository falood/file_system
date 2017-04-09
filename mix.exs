defmodule Mix.Tasks.Compile.Src do
  def run(_) do
    case :os.type() do
      {:unix, :darwin} ->
        Mix.shell.cmd("clang -framework CoreFoundation -framework CoreServices -Wno-deprecated-declarations c_src/mac/*.c -o priv/mac_listener")
      {:unix, :freebsd} ->
        Mix.shell.cmd("cc c_src/bsd/*.c -o priv/kqueue")
      _ -> nil
    end
  end
end

defmodule ExFSWatch.Mixfile do
  use Mix.Project

  def project do
    [ app: :exfswatch,
      version: "0.4.1",
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
       links: %{"Github" => "https://github.com/falood/exfswatch"}
     }
  end
end
