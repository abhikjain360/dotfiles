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

let
  # A clang/cc/clang++/c++ that link with mold by default, so *every* C/C++ build
  # on this user's Linux hosts uses mold — not just Rust (which the cargo config
  # below also covers). Each driver execs the real nixpkgs clang wrapper (so all
  # the include/libc/startfile setup is untouched), only adding the linker:
  #   --ld-path=<mold>  pin mold by absolute path (PATH-independent, unambiguous)
  #   -Wno-unused-...   keep compile-only (-c) runs quiet, since the linker flag
  #                     is unused when not linking.
  # Nix builds and their sandboxed stdenv are deliberately NOT touched (they pin
  # their own toolchains); this only affects compilers *you* invoke. CUDA/nvcc
  # linking is pinned per-project instead.
  moldClang = pkgs.runCommand "clang-mold-${pkgs.clang.version}" { } ''
        mkdir -p $out/bin
        for f in ${pkgs.clang}/bin/*; do
          ln -s "$f" "$out/bin/$(basename "$f")"
        done
        rm -f $out/bin/clang $out/bin/cc $out/bin/clang++ $out/bin/c++
        for c in clang cc; do
          cat > "$out/bin/$c" <<'EOF'
    #!${pkgs.runtimeShell}
    exec ${pkgs.clang}/bin/clang --ld-path=${pkgs.mold}/bin/ld.mold -Wno-unused-command-line-argument "$@"
    EOF
          chmod +x "$out/bin/$c"
        done
        for cxx in clang++ c++; do
          cat > "$out/bin/$cxx" <<'EOF'
    #!${pkgs.runtimeShell}
    exec ${pkgs.clang}/bin/clang++ --ld-path=${pkgs.mold}/bin/ld.mold -Wno-unused-command-line-argument "$@"
    EOF
          chmod +x "$out/bin/$cxx"
        done
  '';
in
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
    ++ lib.optionals pkgs.stdenv.isLinux [
      # Standalone Home Manager installs land in ~/.nix-profile, but Nix's own
      # profile script only adds it to PATH for *login* shells. A non-interactive
      # SSH command (`ssh host cmd`) runs a non-login shell — which is exactly how
      # rsync/git/etc. invoke their remote helper (`ssh host rsync --server …`).
      # Without this entry the remote tool isn't found ("command not found", child
      # exits 127), so `rsync laptop:… host:…` dies with io_read/EOF errors even
      # though `rsync` works in an interactive shell. Threading it through
      # sessionPath puts it in hm-session-vars.sh, which the HM-managed .zshenv
      # sources for non-login shells. No-op on NixOS (useUserPackages has no
      # ~/.nix-profile, and the system already sets a full non-login PATH).
      "$HOME/.nix-profile/bin"
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
        en-croissant
        gh
        runpodctl
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        moldClang # clang/cc/clang++/c++ that default to linking with mold (see `let` above)
        clang-tools # clangd language server (+ clang-format/clang-tidy) for C/C++ editing
        flamegraph
        mold # the fast linker itself + CLI; used by moldClang and by the cargo config below
        valgrind
      ];

    # Build Rust with clang as the link driver and mold as the actual linker
    # (Linux only — macOS ships its own toolchain and mold isn't for Darwin).
    # Scoped to this host's own target triple so cross-compiles are untouched;
    # the triple is taken from nixpkgs so it's correct on x86_64 and aarch64
    # alike. The moldClang from home.packages already defaults to mold, so the
    # -fuse-ld below is redundant — kept so Rust's linker choice is explicit and
    # self-documenting in cargo's own config.
    file = lib.mkIf pkgs.stdenv.isLinux {
      ".cargo/config.toml".text = ''
        [target.${pkgs.stdenv.hostPlatform.config}]
        linker = "clang"
        rustflags = ["-C", "link-arg=-fuse-ld=mold"]
      '';
    };
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
      # Atuin owns Ctrl-R. Its zsh integration is sourced after fzf's and already
      # overrides this key, so drop fzf's Ctrl-R history widget to make that
      # explicit and silence home-manager's conflict warning. fzf keeps Ctrl-T
      # (files) and Alt-C (cd). To flip ownership to fzf instead, remove this line
      # and set `programs.atuin.flags = [ "--disable-ctrl-r" ];`.
      historyWidget.command = "";
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

  xdg.configFile = {
    "beets".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/beets";
    "nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/nvim";
    "zellij".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/zellij";
  };
}
