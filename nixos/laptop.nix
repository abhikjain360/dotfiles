# Headless NixOS test box: Ryzen 7 4800U + RTX 3050 Ti laptop, run lid-closed and
# SSH-only as a disposable dry run for the desktop. No desktop environment. The
# RTX 3050 Ti has no job yet (streaming/CUDA come later) — this is the minimal
# "boots + reachable" system layer. CLI tooling comes from ./common.nix via the flake.
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./laptop-hardware.nix ];

  # Boot: UEFI + systemd-boot.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "laptop";
  networking.networkmanager.enable = true;

  # Firmware for the WiFi card (and GPUs). Without this the wireless NIC may not
  # come up — which would strand a headless box with no way back in.
  hardware.enableRedistributableFirmware = true;

  # Always-on headless box: closing the lid must not suspend it.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  time.timeZone = "Europe/Berlin"; # matches the Mac
  i18n.defaultLocale = "en_US.UTF-8";

  # Compressed RAM swap instead of a swap partition.
  zramSwap.enable = true;

  # noatime on root (merges with the generated fileSystems."/").
  fileSystems."/".options = [ "noatime" ];

  # SSH-only access, keys not passwords.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false; # truly key-only (block the PAM password path)
    };
  };

  programs.zsh.enable = true;

  # UEFI boot-entry management (handy for cleaning stale entries / boot order).
  environment.systemPackages = [ pkgs.efibootmgr ];

  users.users.abhik = {
    isNormalUser = true;
    description = "Abhik Jain";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+Jxw2xXMeEO+1Kud32wQ5Yvd4fw16F3Dzfb14nSOPq abhikjain360@gmail.com"
    ];
    # Temporary console password; SSH uses the key above. Change after first boot.
    initialPassword = "nixos";
  };
  security.sudo.wheelNeedsPassword = false;

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;

  system.stateVersion = "26.05";
}
