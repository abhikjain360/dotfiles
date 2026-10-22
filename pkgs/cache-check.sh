allowed_source_builds=(sofka diesel-cli linear-cli nss-cacert)

if ! plan=$(nix build --dry-run --no-link "$@" 2>&1); then
  printf '%s\n' "$plan" >&2
  exit 1
fi

mapfile -t drvs < <(grep -E '^ +/nix/store/[^ ]+\.drv$' <<<"$plan" | tr -d ' ')
if [[ ${#drvs[@]} -eq 0 ]]; then
  exit 0
fi

source_builds=$(nix derivation show "${drvs[@]}" | jq -r '
  (.derivations // .)[]
  | ((.env // {}) + (.structuredAttrs // {})) as $attrs
  | select($attrs.src != null or $attrs.srcs != null)
  | select(($attrs.preferLocalBuild | . == true or . == "1") or ($attrs.allowSubstitutes | . == false or . == "") | not)
  | select(($attrs.pname // .name) | IN($ARGS.positional[]) | not)
  | .name
' --args "${allowed_source_builds[@]}")

if [[ -n $source_builds ]]; then
  printf 'Not in the binary cache, would build from source:\n%s\n' "$source_builds" >&2
  exit 1
fi
