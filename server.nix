{ pkgs, ... }:

{
  # Server-specific Home Manager additions layered on top of common.nix.
  home.packages = [
    pkgs.rsync # fast file sync for deploying configs/artifacts to this box
    (pkgs.runCommand "cloudflared-2026.10.4" {
      src = pkgs.fetchurl {
        url = "https://github.com/cloudflare/cloudflared/releases/download/2026.10.4/cloudflared-linux-arm64";
        hash = "sha256-K3IDtPsLoooMHhL4hVziwl920mao1e2vrFVAtoEqz/Y=";
      };
    } "install -Dm755 $src $out/bin/cloudflared")
  ];
}
