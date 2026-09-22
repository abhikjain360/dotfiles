{ config, lib, ... }:

let
  user = lib.escapeShellArg config.system.primaryUser;

  # These preferences use CFPreferences' current-host scope. Resolve the host at
  # activation time so the same settings apply on every Mac, without UUIDs.
  currentHostPreferences = {
    NSGlobalDomain = {
      "com.apple.trackpad.enableSecondaryClick" = true;
      # Caps Lock -> Escape as System Settings stores it. This is the form that
      # survives a reboot; the hidutil mapping in system.keyboard does not.
      "com.apple.keyboard.modifiermapping.0-0-0" = [
        {
          HIDKeyboardModifierMappingDst = 30064771113;
          HIDKeyboardModifierMappingSrc = 30064771129;
        }
      ];
    };
    "com.apple.controlcenter".Display = 24; # Hide the display menu-bar control.
    "com.apple.screensaver".idleTime = 0; # Never start the screen saver on idle.
  };
in
{
  users.users.abhik.home = "/Users/abhik";

  home-manager.users.abhik =
    { config, ... }:
    let
      dotfiles = "${config.home.homeDirectory}/.config/home-manager";
    in
    {
      home.file = {
        ".codex/config.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/codex/config.toml";

        ".local/bin/codex".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/codex/bin/codex";
      };

      # Only config.toml: alauncher's secrets.toml (API keys) stays a plain local
      # file beside it, outside this repo.
      xdg.configFile."alauncher/config.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/alauncher/config.toml";

      programs.zsh.shellAliases.codex = "$HOME/.local/bin/codex";
    };

  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      # Route pass's clipboard copy through a shim that tags the macOS pasteboard
      # with the nspasteboard.org "concealed" type, so Clipper (and other
      # clipboard history/sync tools) skip copied passwords. Upstream pass's
      # Darwin clip() does a plain `pbcopy`, which carries no such marker, so the
      # password otherwise looks like ordinary text and gets captured/synced.
      pass =
        let
          conceal-copy-js = prev.writeText "conceal-copy.js" ''
            ObjC.import("AppKit");
            function run() {
              var d = $.NSFileHandle.fileHandleWithStandardInput.readDataToEndOfFile;
              var s = $.NSString.alloc.initWithDataEncoding(d, $.NSUTF8StringEncoding);
              if (!s || s.isNil()) s = $("");
              var pb = $.NSPasteboard.generalPasteboard;
              var concealed = $("org.nspasteboard.ConcealedType");
              pb.clearContents;
              pb.declareTypesOwner($([concealed, $.NSPasteboardTypeString]), $());
              pb.setStringForType(s, $.NSPasteboardTypeString);
              pb.setStringForType(s, concealed);
            }
          '';
          # pass's Darwin clip() calls a bare `pbcopy`; shadow it on pass's PATH.
          conceal-pbcopy = prev.writeShellScriptBin "pbcopy" ''
            exec /usr/bin/osascript -l JavaScript ${conceal-copy-js}
          '';
        in
        prev.symlinkJoin {
          name = "pass-conceal";
          paths = [ prev.pass ];
          nativeBuildInputs = [ prev.makeWrapper ];
          postBuild = "wrapProgram $out/bin/pass --prefix PATH : ${conceal-pbcopy}/bin";
        };
    })
  ];

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    # pam_reattach, so Touch ID for sudo also works inside zellij/tmux.
    reattach = true;
  };

  services.openssh.enable = true; # Remote Login; launchctl print-disabled system shows com.openssh.sshd enabled

  networking = {
    knownNetworkServices = [ "Wi-Fi" ];
    dns = [ "1.1.1.1" ];

    # Live state from `socketfilterfw --getglobalstate --getblockall
    # --getstealthmode --getallowsigned`. /Library/Preferences/com.apple.alf.plist
    # no longer exists on macOS 26, so never infer the firewall state from it.
    # The Vanta compliance agent is installed and typically checks this.
    applicationFirewall = {
      enable = true;
      blockAllIncoming = false;
      allowSigned = true;
      allowSignedApp = true;
      enableStealthMode = false;
    };
  };

  power = {
    # From `sudo systemsetup -getrestartfreeze`. restartAfterPowerFailure is
    # "Not supported on this machine", so it stays unset.
    restartAfterFreeze = true;
    sleep = {
      computer = 1;
      harddisk = 10;
      allowSleepByPowerButton = true;
      # The display timeout differs between battery and AC; see
      # system.activationScripts.power below.
    };
  };

  launchd.user.agents.ssh-load-keys = {
    command = "/Users/abhik/.ssh/load-keys.sh";
    serviceConfig = {
      RunAtLoad = true;
      StandardOutPath = "/tmp/ssh-load-keys.log";
      StandardErrorPath = "/tmp/ssh-load-keys.log";
    };
  };

  system = {
    primaryUser = "abhik";
    stateVersion = 6;

    # macOS settings. Audited 2026-09-22 on macOS 26.6.2 (25G83) with nix-darwin
    # 4cff07d by reading live state: defaults read (user, -currentHost and
    # /Library/Preferences domains), pmset -g custom, socketfilterfw,
    # networksetup, scutil, sysadminctl -screenLock status, launchctl
    # print-disabled system. Every value below matched the Mac at audit time.
    # Deliberately unmanaged, with reasons:
    # - Screen lock: sysadminctl reports a 60 s delay. The legacy
    #   com.apple.screensaver askForPassword* keys that screensaver.* would write
    #   are absent and are not what macOS 26 enforces, so leave screensaver.* unset.
    # - time.timeZone: automatic time zone is on (com.apple.timezone.auto
    #   Active=1, currently resolving to Europe/Berlin); pinning would fight it.
    # - smb.NetBIOSName / ServerDescription: auto-derived from the computer name.
    # - Control Center: only Display=24 is a plain key; the rest of the menu-bar
    #   layout is opaque serialized state.
    # - Wallpaper, display arrangement, TCC/privacy grants, Bluetooth pairing,
    #   Wi-Fi credentials, Focus/notification rules, FileVault, Gatekeeper and
    #   SIP (all on): no nix-darwin option.
    # - Third-party launchd daemons (cloudflared, docker, podman helper, iBoysoft
    #   NTFS, Vanta) come from their own installers, not launchd.daemons.
    # - Verified with sudo: /etc/sudoers is stock macOS (no security.sudo.*
    #   needed); network time is on with the default time.euro.apple.com (no
    #   nix-darwin option).
    # - Every other system.defaults option had no stored value on this Mac, i.e.
    #   macOS default; keep unset.

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    activationScripts = {
      # nix-darwin's power.sleep.display and networking.wakeOnLan options cannot
      # express separate battery/AC values. Only touch profiles the Mac provides.
      power.text = lib.mkAfter ''
        if /usr/bin/pmset -g custom | /usr/bin/grep -q '^Battery Power:'; then
          /usr/bin/pmset -b displaysleep 2 womp 0 lessbright 1
          if /usr/bin/pmset -g cap | /usr/bin/grep -q '^[[:space:]]*lowpowermode$'; then
            /usr/bin/pmset -b lowpowermode 1
          fi
        fi
        if /usr/bin/pmset -g custom | /usr/bin/grep -q '^AC Power:'; then
          /usr/bin/pmset -c displaysleep 5 womp 1
          if /usr/bin/pmset -g cap | /usr/bin/grep -q '^[[:space:]]*lowpowermode$'; then
            /usr/bin/pmset -c lowpowermode 0
          fi
        fi
      '';

      # CustomUserPreferences has no current-host variant. Use the same user
      # context as nix-darwin's defaults writer, with -currentHost.
      userDefaults.text = lib.mkAfter (
        lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            domain: preferences:
            lib.concatStringsSep "\n" (
              lib.mapAttrsToList (
                key: value:
                ''launchctl asuser "$(id -u -- ${user})" sudo --user=${user} -- defaults -currentHost write ${lib.escapeShellArg domain} ${lib.escapeShellArg key} ${
                  lib.escapeShellArg (lib.generators.toPlist { escape = true; } value)
                }''
              ) preferences
            )
          ) currentHostPreferences
        )
        + "\n"
      );
    };

    defaults = {
      # Stable preferences without dedicated nix-darwin options.
      CustomUserPreferences.NSGlobalDomain = {
        AppleLanguages = [
          "en-US"
          "de-DE"
        ];
        AppleLocale = "en_US@rg=dezzzz";
        AppleMenuBarVisibleInFullscreen = true;
        AppleMiniaturizeOnDoubleClick = false;
        NSCloseAlwaysConfirmsChanges = true;
      };
      CustomUserPreferences."com.apple.finder".ShowSidebar = true;

      CustomSystemPreferences = {
        "/Library/Preferences/.GlobalPreferences" = {
          AppleLanguages = [
            "en-US"
            "de-DE"
          ];
          AppleLocale = "en_US@rg=dezzzz";
        };
        "/Library/Preferences/com.apple.SoftwareUpdate" = {
          AutomaticDownload = true;
          ConfigDataInstall = true;
          CriticalUpdateInstall = true;
          SplatEnabled = true;
        };
        "/Library/Preferences/com.apple.commerce".AutoUpdate = false;
        # Keep automatic timezone selection instead of pinning Europe/Berlin.
        "/Library/Preferences/com.apple.timezone.auto".Active = true;
      };

      CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys =
        let
          off = {
            enabled = false;
          };
          on = {
            enabled = true;
          };
          # [ <key-char> <key-code> <modifier-mask> ]; all of these are disabled.
          binding = parameters: {
            enabled = false;
            value = {
              inherit parameters;
              type = "standard";
            };
          };
        in
        {
          "15" = off; # Mission Control: Application windows
          "16" = off;
          "17" = off;
          "18" = off;
          "19" = off;
          "20" = off;
          "21" = off;
          "22" = off;
          "23" = off;
          "24" = off;
          "25" = off;
          "26" = off;
          "30" = binding [
            52
            21
            1179648
          ]; # Screenshots
          "31" = binding [
            52
            21
            1441792
          ];
          "60" = binding [
            32
            49
            262144
          ]; # Select previous/next input source
          "61" = binding [
            32
            49
            786432
          ];
          "64" = binding [
            32
            49
            1048576
          ]; # Spotlight search (cmd+space) — DISABLED for alauncher
          "65" = binding [
            32
            49
            1572864
          ]; # Finder search window (cmd+opt+space) — DISABLED
          "79" = on; # Move to space left/right etc.
          "80" = on;
          "81" = on;
          "82" = on;
          "164" = binding [
            65535
            65535
            0
          ];
        };

      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        KeyRepeat = 1;
        InitialKeyRepeat = 15;
        AppleShowAllExtensions = true;
        NSTableViewDefaultSizeMode = 1;
        NSAutomaticCapitalizationEnabled = true;
        NSAutomaticPeriodSubstitutionEnabled = true;
        _HIHideMenuBar = false;
        "com.apple.springing.delay" = 0.5;
        "com.apple.springing.enabled" = true;
        "com.apple.swipescrolldirection" = true;
        "com.apple.trackpad.enableSecondaryClick" = true;
        "com.apple.trackpad.forceClick" = true;
      };

      dock = {
        autohide = true;
        autohide-delay = 1000.0; # Preserve the effectively hidden Dock.
        autohide-time-modifier = 0.0;
        orientation = "left";
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
        target = "file";
      };

      loginwindow = {
        GuestEnabled = false;
        SHOWFULLNAME = false;
      };

      WindowManager = {
        AppWindowGroupingBehavior = true;
        AutoHide = false;
        EnableTiledWindowMargins = false;
        HideDesktop = true;
        StageManagerHideWidgets = false;
        StandardHideWidgets = false;
      };

      menuExtraClock = {
        ShowAMPM = true;
        ShowDate = 0;
        ShowDayOfWeek = true;
      };

      # nix-darwin writes both built-in and Bluetooth trackpad domains.
      trackpad = {
        ActuateDetents = true;
        Clicking = false;
        DragLock = false;
        Dragging = false;
        FirstClickThreshold = 1;
        ForceSuppressed = false;
        SecondClickThreshold = 1;
        TrackpadCornerSecondaryClick = 0;
        TrackpadFourFingerHorizSwipeGesture = 2;
        TrackpadFourFingerPinchGesture = 2;
        TrackpadFourFingerVertSwipeGesture = 2;
        TrackpadMomentumScroll = true;
        TrackpadPinch = true;
        TrackpadRightClick = true;
        TrackpadRotate = true;
        TrackpadThreeFingerDrag = false;
        TrackpadThreeFingerHorizSwipeGesture = 2;
        TrackpadThreeFingerTapGesture = 0;
        TrackpadThreeFingerVertSwipeGesture = 2;
        TrackpadTwoFingerDoubleTapGesture = true;
        TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
      };

      magicmouse.MouseButtonMode = "OneButton";
      universalaccess.reduceTransparency = true;
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      iCal.CalendarSidebarShown = true;
      ActivityMonitor = {
        OpenMainWindow = true;
        ShowCategory = 102; # My Processes.
      };
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
      "choose-gui"
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
      "codex"
      "chatgpt"
      "claude"
      "discord"
      "firefox"
      "flameshot"
      "flutter"
      "ghostty"
      "google-chrome"
      "kimi"
      "monitorcontrol"
      "obs"
      "scroll-reverser"
      "slack"
      "steam"
      "syncthing-app"
      "tailscale-app"
      "xournal++"
    ];
  };
}
