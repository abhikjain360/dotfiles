# Headless NixOS test box: Ryzen 7 4800U + RTX 3050 Ti laptop, run lid-closed and
# SSH-only as a disposable dry run for the desktop. No desktop environment. The
# RTX 3050 Ti now has the NVIDIA driver loaded (PRIME offload over the AMD Renoir
# iGPU) so nvidia-smi/CUDA/NVENC work; the streaming (Steam/gamescope) layer comes
# later. CLI tooling comes from ./common.nix via the flake.
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

  # --- GPU: AMD Renoir iGPU + NVIDIA RTX 3050 Mobile (hybrid) ---------------
  # Mesa/Vulkan/VA-API userspace for both GPUs (NVENC/CUDA use this too).
  hardware.graphics.enable = true;

  # Canonical NVIDIA switch. On a headless box this just loads the kmod +
  # userspace; it does NOT start an X server (no DM/DE is enabled).
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    # GA107 is Ampere → use the open kernel modules (recommended for Turing+).
    open = true;
    # Headless: no nvidia-settings GUI tool.
    nvidiaSettings = false;
    # Keep the GPU initialized without an X server (headless compute/stream).
    nvidiaPersistenced = true;
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Hybrid laptop: PRIME offload. iGPU is the nominal primary (low power);
    # the dGPU spins up on demand (nvidia-smi, or apps launched via the
    # `nvidia-offload` wrapper / __NV_PRIME_RENDER_OFFLOAD). Bus IDs are
    # per-machine, read off this box with `lspci -D` (decimal B:D:F).
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true; # provides the `nvidia-offload` wrapper
      nvidiaBusId = "PCI:1:0:0"; # 0000:01:00.0 GA107M
      amdgpuBusId = "PCI:5:0:0"; # 0000:05:00.0 Renoir
    };
  };

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

  # --- Game streaming: Sunshine host, Moonlight client on the Mac ----------
  # The game runs HERE (RTX 3050 renders + NVENC-encodes); the Mac is a thin
  # client. Steam installs games onto this box's NVMe and executes them.
  #
  # Capture surface = a HEADLESS sway session (below). Sunshine needs a wlroots
  # compositor that exposes xdg_output + wlr-screencopy; gamescope can't be
  # captured (no xdg_output, and its headless backend has no KMS scanout), so
  # sway's userspace headless output is the surface. gamescope stays available
  # as an optional per-game nested layer.
  programs.steam = {
    enable = true; # pulls 32-bit graphics + the full client; games live here
    remotePlay.openFirewall = false; # streaming via Sunshine, not Steam Remote Play
  };
  programs.gamescope.enable = true; # optional per-game nesting (not the capture surface)

  # PipeWire carries the streamed game audio (Sunshine creates a virtual sink
  # and captures its monitor — no speakers needed on this headless box).
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Seat provider so sway's libinput backend can open input devices headlessly
  # (no logind graphical session, no VT).
  services.seatd.enable = true;

  services.sunshine = {
    enable = true;
    openFirewall = true; # 47984-48010 TCP/UDP + the 47990 web UI
    # capSysAdmin is ONLY for KMS capture on non-wlroots compositors. We capture
    # sway via wlr-screencopy (no KMS), and the controller's uinput works via the
    # group, not cap_sys_admin. Crucially, setcap makes ld.so ignore library
    # paths → NVENC can't find libcuda.so.1. So keep it OFF.
    capSysAdmin = false;
    autoStart = false; # started from inside the sway session so it inherits WAYLAND_DISPLAY
  };
  systemd.user.services.sunshine.environment = {
    LD_LIBRARY_PATH = "/run/opengl-driver/lib"; # so any GPU encoder can dlopen its libs
    LIBVA_DRIVER_NAME = "radeonsi"; # AMD VCN encoder, not nvidia's decode-only VAAPI
  };

  # Headless capture session: sway with the userspace headless backend creates a
  # virtual 1080p output with no seat/monitor, pinned to the NVIDIA render node
  # (renderD128) so capture and NVENC stay on one GPU. Once up it imports its
  # WAYLAND_DISPLAY into the user manager and starts the (NVENC-capable) Sunshine
  # service. Steam Big Picture gets exec'd here in the next step.
  systemd.user.services.sway-stream = {
    description = "Headless sway session — Sunshine capture surface";
    wantedBy = [ "default.target" ]; # user lingers, so this comes up at boot
    path = [
      pkgs.bash
      pkgs.systemd
      config.programs.steam.package # `steam` for the Big Picture exec below
    ]; # sway's `exec` runs via sh -c → needs a shell + systemctl in PATH
    environment = {
      # gles2, NOT vulkan: on NVIDIA 595.x the wlroots vulkan renderer hands
      # wlr-screencopy compressed-modifier buffers that fail to capture
      # ("Couldn't scale frame: Invalid argument"). gles2 fixes capture.
      # libinput backend so sway reads Sunshine's uinput devices (without it,
      # headless has NO input → controller/kbd/mouse do nothing). libinput needs
      # a seat: seatd (below) provides one without a VT.
      WLR_BACKENDS = "libinput,headless";
      WLR_LIBINPUT_NO_DEVICES = "1"; # start the backend with no devices; hotplug uinput later
      LIBSEAT_BACKEND = "seatd"; # use seatd, not the VT-requiring builtin backend
      WLR_RENDERER = "gles2";
      WLR_DRM_NO_MODIFIERS = "1"; # linear buffers (belt-and-suspenders for clean capture)
      # Composite + capture on the AMD iGPU (renderD129). NVIDIA's wlr-screencopy
      # buffers corrupt under Sunshine (garble + NVENC scale-fail); radeonsi is
      # well-behaved and the Renoir VCN encodes via VAAPI on the SAME GPU as the
      # capture (no cross-GPU). The RTX 3050 still renders games via PRIME offload.
      WLR_RENDER_DRM_DEVICE = "/dev/dri/renderD129"; # AMD Renoir iGPU
      WLR_NO_HARDWARE_CURSORS = "1";
      XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_TYPE = "wayland";
    };
    serviceConfig = {
      Type = "simple";
      # --unsupported-gpu: wlroots refuses the NVIDIA proprietary driver without it.
      ExecStart = "${lib.getExe pkgs.sway} --unsupported-gpu -c ${pkgs.writeText "sway-stream.conf" ''
        output HEADLESS-1 mode 1920x1080@60Hz
        exec systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && systemctl --user start sunshine.service
        exec __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia steam -gamepadui
      ''}";
      # ^ PRIME offload on the Steam launch: Steam + every game it spawns render
      # on the RTX 3050 (dGPU), presenting frames back to the iGPU-composited
      # session. sway itself stays on the iGPU (clean capture); only rendering
      # moves to the dGPU. Per-game override still possible via Steam launch opts.
      Restart = "on-failure";
      RestartSec = "3s";
    };
  };

  # Run the user systemd manager at boot even with nobody logged in, so the
  # sway-stream + Sunshine services come up headless.
  users.users.abhik.linger = true;

  # UEFI boot-entry management (handy for cleaning stale entries / boot order).
  environment.systemPackages = [ pkgs.efibootmgr ];

  users.users.abhik = {
    isNormalUser = true;
    description = "Abhik Jain";
    extraGroups = [
      "wheel"
      "networkmanager"
      # Streaming: Sunshine runs as this user's service. uinput = create the
      # virtual gamepad/kbd/mouse Moonlight forwards into; video/render = GPU
      # render-node access for the headless gamescope session (no seat means no
      # automatic device ACLs).
      "uinput"
      "video"
      "render"
      "seat" # access /run/seatd.sock (owned root:seat) so sway's libinput backend can open input devices
      # Read /dev/input/event* directly: games/Steam read gamepads from evdev (no
      # Wayland gamepad protocol), so without this the virtual Xbox pad is unreadable
      # even though kbd/mouse work (those come through sway over Wayland).
      "input"
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
