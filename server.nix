{ pkgs, ... }:

{
  # Server-specific Home Manager additions layered on top of common.nix.
  home.packages = [
    pkgs.rsync # fast file sync for deploying configs/artifacts to this box
    pkgs.cloudflared # Cloudflare Tunnel daemon fronting api.clipper.abhikja.in
  ];
}
