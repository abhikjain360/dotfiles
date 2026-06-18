{
  lib,
  ...
}:

# RunPod GPU box profile.
#
# Intentionally thin: it reuses the whole environment from common.nix (zsh,
# nvim, zellij, git, rustup, direnv, ...) and only adjusts what has to differ
# inside a RunPod container.
#
# CUDA lives nowhere in here. Each learning project pulls NVIDIA's cuda-oxide
# flake (CUDA 13 + LLVM 22 + nightly Rust) on its own via `nix develop` /
# direnv; this profile is purely your editor/shell/tooling ergonomics.
{
  # RunPod containers run as root, so target root's home instead of the
  # /home/abhik that common.nix assumes for Linux.
  home.username = lib.mkForce "root";
  home.homeDirectory = lib.mkForce "/root";

  # RunPod-only extras go here as you grow into them, e.g.:
  # home.packages = with pkgs; [ just cargo-nextest ];
}
