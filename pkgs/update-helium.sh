set -euo pipefail

out="$(dirname "$0")/helium.json"

curl -fsSL https://api.github.com/repos/imputnet/helium-linux/releases/latest |
  jq -e '
    {
      version: .tag_name,
      sha256: (
        [
          .assets[]
          | (.name | capture("-(?<arch>x86_64|arm64)_linux\\.tar\\.xz$")) as $m
          | { key: $m.arch, value: (.digest | ltrimstr("sha256:")) }
        ]
        | from_entries
      )
    }
    | select((.sha256 | keys) == ["arm64", "x86_64"])
  ' >"$out.new"

mv "$out.new" "$out"
jq -r '"helium \(.version)"' "$out"
