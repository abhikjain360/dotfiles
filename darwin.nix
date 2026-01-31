{
  _,
  ...
}:

{
  users.users.abhik.home = "/Users/abhik";
  system.primaryUser = "abhik";

  nix.enable = false;

  system.stateVersion = 6;

  nixpkgs.config.allowUnfree = true;

  security.pam.services.sudo_local.touchIdAuth = true;

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
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    brews = [
      "pinentry-mac"
    ];
    casks = [
      "android-platform-tools"
      "android-studio"
      "battery"
      "brave-browser"
      "cursor"
      "discord"
      "firefox"
      "flameshot"
      "ghostty"
      "google-chrome"
      "monitorcontrol"
      "mpv"
      "musicbrainz-picard"
      "obs"
      "raycast"
      "scroll-reverser"
      "slack"
      "tailscale-app"
      "xournal-plus-plus"
      "zed"
    ];
  };
}
