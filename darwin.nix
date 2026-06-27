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
      home.file = {
        ".codex/config.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/codex/config.toml";

        ".codex/hooks/nix_bash.py".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/codex/hooks/nix_bash.py";

        ".local/bin/codex".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/codex/bin/codex";
      };

      programs.zsh.shellAliases.codex = "$HOME/.local/bin/codex";
    };

  nix.enable = false;

  system.stateVersion = 6;

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      direnv = nixpkgs-direnv.legacyPackages.${final.system}.direnv;

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
    # Keep cmd+space free for Raycast. macOS owns it via symbolic hotkey 64
    # ("Show Spotlight search"); disabling that hotkey with a real boolean is
    # what frees the combo. nix-darwin writes the whole AppleSymbolicHotKeys
    # dict at once, so every current hotkey is listed here to preserve it.
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
        ]; # Spotlight search (cmd+space) — DISABLED for Raycast
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
      # Remove once nix-darwin#1787/#1789 lands and this flake input is updated.
      extraFlags = [ "--force-cleanup" ];
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
      "codex"
      "discord"
      "firefox"
      "flameshot"
      "flutter"
      "ghostty"
      "google-chrome"
      "monitorcontrol"
      "moonlight" # Moonlight client — streams games from the laptop's Sunshine host
      "obs"
      "raycast"
      "scroll-reverser"
      "slack"
      "steam"
      "syncthing-app"
      "tailscale-app"
      "xournal++"
    ];
  };
}
