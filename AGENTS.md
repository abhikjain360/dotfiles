Personal dotfiles as a single Nix flake managing nix-darwin (macOS), NixOS, and
standalone Home Manager hosts.

- `flake.nix` is the single entry point: all hosts, all inputs.
- `common.nix` is the shared Home Manager module — most changes land there.
  `darwin.nix`, `nixos/laptop.nix`, `desktop.nix`, and the thin per-host modules
  layer on top.
- Tool configs (nvim, zellij, ghostty, etc.) are symlinked out of the Nix
  store back into this checkout, so they can be edited live without a rebuild.
- Never commit secrets.
