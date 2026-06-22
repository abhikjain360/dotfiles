{
  config,
  pkgs,
  lib,
  isArchLinux,
  bookmarks-yazi,
  # Enable GPG commit/tag signing on this host. Only hosts where the key is
  # reachable set this true: the Mac (native key) and the laptop (key forwarded
  # over SSH from the Mac). Keyless hosts pass false so their commits don't fail.
  # (Passed by every host, like isArchLinux — a module-arg default isn't honored
  # by the module system when the arg is simply omitted.)
  gpgSign,
  ...
}:

{
  home = {
    username = "abhik";
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/abhik" else "/home/abhik";
    stateVersion = "26.05";

    # We track nixos-unstable for nixpkgs and master for Home Manager. After a
    # release branches, HM master bumps its version tag ahead of unstable
    # nixpkgs, so their release strings differ even though both are unstable
    # builds from the same week. The skew is harmless here, so silence the check.
    enableNixpkgsReleaseCheck = false;

    sessionVariables = {
      EDITOR = "nvim";
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      HOMEBREW_PREFIX = "/opt/homebrew";
      HOMEBREW_CELLAR = "/opt/homebrew/Cellar";
      HOMEBREW_REPOSITORY = "/opt/homebrew";
      INFOPATH = "/opt/homebrew/share/info:\${INFOPATH:-}";
    };

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.opencode/bin"
      "$HOME/.cargo/bin"
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
      "$HOME/.cabal/bin"
      "$HOME/.ghcup/bin"
    ];

    packages =
      with pkgs;
      [
        bat
        bun
        curl
        difftastic
        dprint
        eza
        fd
        git-lfs
        go
        gnupg
        htop
        jq
        lazyjj
        libopus
        libopus.dev
        neovim
        nixfmt
        nodejs_24
        pkgconf
        podman
        podman-compose
        ripgrep
        rustup
        sd
        statix
        uv
        zellij
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
        coreutils
        gh
        runpodctl
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        valgrind
        flamegraph
      ];
  };

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = "Abhik Jain";
          email = "abhik@abhikjain.xyz";
        }
        // lib.optionalAttrs gpgSign {
          signingkey = "81521AB49BF9D100AEAB66DD74BF75B80750FD6B";
        };
        init.defaultBranch = "main";
        core.compression = 0;
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        pack.windowsMemory = "256m";
        http.postBuffer = 524288000;
      }
      // lib.optionalAttrs gpgSign {
        commit.gpgsign = true;
        tag.gpgSign = true;
        gpg.program = "${pkgs.gnupg}/bin/gpg";
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        light = false;
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        time.disabled = false;
      };
    };

    zsh = {
      enable = true;
      autocd = true;
      defaultKeymap = "viins";

      initContent = lib.mkOrder 525 (
        lib.optionalString pkgs.stdenv.isDarwin ''
          if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
            fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
          fi
        ''
      );

      history = {
        path = "$HOME/.zsh_history";
        size = 10000;
        save = 100000;
        extended = true;
      };

      setOptions = [
        "extendedglob"
        "notify"
      ];

      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      historySubstringSearch = {
        enable = true;
        searchUpKey = "^[[A";
        searchDownKey = "^[[B";
      };

      shellAliases = {
        v = "nvim";
        la = "eza -la --group-directories-first";

        # cargo
        cb = "cargo build";
        cbr = "cargo build --release";
        cr = "cargo run";
        crr = "cargo run --release";
        ct = "cargo test";
        ctr = "cargo test --release";

        # git
        gc = "git checkout";
        gcm = "git checkout main";
        gcb = "git checkout -b";
        gs = "git stash";
        gb = "git branch";
        gbd = "git branch -D";
        gpl = "git pull";
        gp = "git push";
        lg = "lazygit";

        # docker
        sdk = "sudo systemctl start docker.service";
        qdk = "sudo systemctl stop docker.service";
        dks = "docker start";
        dkq = "docker stop";
        dki = "docker images";
        dkp = "docker ps -a";

        # podman
        spd = "podman machine start";
        pc = "podman-compose";

        # zellij
        zs = "zellij -s";
        zsa = "zellij -s a";
        zda = "zellij da";
        zka = "zellij ka";

        # update
        dr = lib.mkIf pkgs.stdenv.isDarwin "sudo darwin-rebuild switch --flake \"$HOME/.config/home-manager#Luminerds-Laptop\"";
        update_all =
          if pkgs.stdenv.isDarwin then
            "dr && rustup update && cargo install-update --all"
          else
            "rustup update && cargo install-update --all";
      }
      // lib.optionalAttrs isArchLinux {
        # paru (arch)
        psu = "paru -S --needed --noconfirm";
        psy = "paru -Syu --needed --noconfirm";
        pss = "paru -Ss";
      };
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;

      plugins = {
        bookmarks = bookmarks-yazi;
      };

      keymap = {
        mgr.prepend_keymap = [
          {
            on = [ "m" ];
            run = "plugin bookmarks save";
            desc = "Save current position as a bookmark";
          }
          {
            on = [ "'" ];
            run = "plugin bookmarks jump";
            desc = "Jump to a bookmark";
          }
          {
            on = [
              "b"
              "d"
            ];
            run = "plugin bookmarks delete";
            desc = "Delete a bookmark";
          }
          {
            on = [
              "b"
              "D"
            ];
            run = "plugin bookmarks delete_all";
            desc = "Delete all bookmarks";
          }
        ];
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    atuin = {
      enable = true;
      enableZshIntegration = true;
    };

    home-manager.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    lazygit = {
      enable = true;
      settings = {
        git = {
          pagers = [
            {
              colorArg = "always";
              pager = "delta --dark --paging=never";
            }
            {
              externalDiffCommand = "difft --color=always";
            }
          ];
        };
        os = {
          edit = ''[ -z "$NVIM" ] && nvim -- {{filename}} || nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}}'';
          editAtLine = ''[ -z "$NVIM" ] && nvim +{{line}} -- {{filename}} || nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}} && nvim --server "$NVIM" --remote-send ":{{line}}<CR>"'';
        };
      };
    };

    jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Abhik Jain";
          email = "abhik@abhikjain.xyz";
        };
        ui = {
          pager = "delta";
          default-command = "log";
          diff-formatter = ":git";
        };
      }
      // lib.optionalAttrs gpgSign {
        signing = {
          behavior = "own"; # sign commits I author; "force" = all, "drop" = off
          backend = "gpg";
          key = "81521AB49BF9D100AEAB66DD74BF75B80750FD6B";
        };
      };
    };
  };

  # On the laptop (Linux + signing enabled) keep a user gpg-agent running so the
  # socket dir /run/user/<uid>/gnupg exists at boot (it lives on tmpfs). When the
  # Mac connects, its forwarded socket replaces this agent's socket (thanks to
  # sshd's StreamLocalBindUnlink), so signing actually runs on the Mac. The Mac
  # itself uses its own native gpg-agent, so this stays off there (isLinux guard).
  services.gpg-agent = lib.mkIf (gpgSign && pkgs.stdenv.isLinux) {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
  };

  xdg.configFile = {
    "beets".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/beets";
    "nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/nvim";
    "zellij".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/zellij";
  };
}
