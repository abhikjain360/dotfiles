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

  # `oxnew <name>`: scaffold a cuda-oxide project AND pin it to the image's
  # prewarmed cuda-oxide ref, so the first `nix develop` is an instant cache
  # hit. Upstream's `#new` template points the generated flake at the moving
  # `main` branch, which would otherwise force a multi-GB CUDA re-download.
  programs.zsh.initContent = lib.mkOrder 550 ''
    export CUDA_OXIDE_REF=v0.2.1
    oxnew() {
      local ref=''${CUDA_OXIDE_REF:-v0.2.1}
      [ -z "$1" ] && { echo "usage: oxnew <project-name>"; return 1; }
      nix run "github:NVlabs/cuda-oxide/$ref#new" "$1" || return 1
      cd "$1" || return 1
      sed -i "s#github:NVlabs/cuda-oxide\"#github:NVlabs/cuda-oxide/$ref\"#" flake.nix
      rm -f flake.lock
      echo "oxnew: pinned cuda-oxide $ref -> run 'direnv allow' or 'nix develop'"
    }
  '';

  # RunPod-only extras go here as you grow into them, e.g.:
  # home.packages = with pkgs; [ just cargo-nextest ];
}
