{
  _,
  nixpkgs-direnv,
  ...
}:

{
  users.users.abhik.home = "/Users/abhik";
  system.primaryUser = "abhik";

  home-manager.users.abhik =
    { config, ... }:
    {
      home.file.".codex/config.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/codex/config.toml";
    };

  nix.enable = false;

  system.stateVersion = 6;

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      direnv = nixpkgs-direnv.legacyPackages.${final.system}.direnv;
    })
  ];

  security.pam.services.sudo_local.touchIdAuth = true;

  launchd.user.agents.ssh-load-keys = {
    command = "/Users/abhik/.ssh/load-keys.sh";
    serviceConfig = {
      RunAtLoad = true;
      StandardOutPath = "/tmp/ssh-load-keys.log";
      StandardErrorPath = "/tmp/ssh-load-keys.log";
    };
  };

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 1;
      InitialKeyRepeat = 15;
      AppleShowAllExtensions = true;
      NSTableViewDefaultSizeMode = 1;
      "com.apple.swipescrolldirection" = true;
      "com.apple.trackpad.forceClick" = true;
    };

    dock = {
      autohide = true;
      persistent-apps = [ ];
      persistent-others = [ ];
      wvous-br-corner = 14;
    };

    finder = {
      FXPreferredViewStyle = "clmv";
      FXRemoveOldTrashItems = true;
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowRemovableMediaOnDesktop = true;
      FXDefaultSearchScope = "SCcf";
    };

    screencapture = {
      location = "~/Documents";
    };

    loginwindow = {
      SHOWFULLNAME = false;
    };

    WindowManager = {
      HideDesktop = true;
      StandardHideWidgets = false;
    };

    menuExtraClock = {
      ShowAMPM = true;
      ShowDate = 0;
      ShowDayOfWeek = true;
    };
  };

  homebrew = {
    enable = true;
    greedyCasks = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    brews = [
      "autoconf"
      "automake"
      "chromaprint"
      "cocoapods"
      "libtool"
      "mpv"
      "opus"
      "pi-coding-agent"
      "pinentry-mac"
      "pkg-config"
    ];
    casks = [
      "adobe-digital-editions"
      "android-platform-tools"
      "android-studio"
      "brave-browser"
      "calibre"
      "claude"
      "codex"
      "discord"
      "firefox"
      "flameshot"
      "flutter"
      "ghostty"
      "google-chrome"
      "monitorcontrol"
      "musicbrainz-picard"
      "obs"
      "raycast"
      "scroll-reverser"
      "slack"
      "steam"
      "syncthing-app"
      "tailscale-app"
      "xournal++"
      "zed"
    ];
  };
}
