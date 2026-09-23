{
  config,
  pkgs,
  lib,
  isArchLinux,
  # Headless boxes (server, workserver, runpod): skip interactive-host extras
  # like podman.
  isServer,
  bookmarks-yazi,
  # GPG commit/tag signing; true only where the key is reachable (Mac: native
  # key; laptop: agent forwarded over SSH from the Mac).
  gpgSign,
  ...
}:

let
  # This repo — the base for the out-of-store config symlinks below.
  dotfiles = "${config.home.homeDirectory}/.config/home-manager";

  # Platform checks; stdenv.isDarwin/isLinux are deprecated on modern nixpkgs.
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;

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
    homeDirectory = if isDarwin then "/Users/abhik" else "/home/abhik";
    stateVersion = "26.05";

    # nixpkgs is nixos-unstable, Home Manager is master. After each release
    # branch-off HM bumps its release string a few weeks before unstable does,
    # and the check only warns about that skew. Permanent, not a workaround.
    enableNixpkgsReleaseCheck = false;

    sessionVariables = {
      EDITOR = "nvim";
    }
    // lib.optionalAttrs isDarwin {
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
    ++ lib.optionals isLinux [
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
    ++ lib.optionals isDarwin [
      # Prefer Home Manager packages when Homebrew provides the same command.
      "${config.home.profileDirectory}/bin"
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
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
        neovim
        nixfmt
        nodejs_24
        pkgconf
        ripgrep
        rustup
        sd
        statix
        uv
        zellij
      ]
      ++ lib.optionals isDarwin [
        coreutils
        en-croissant
        gh
        runpodctl
      ]
      ++ lib.optionals isLinux [
        moldClang # clang/cc/clang++/c++ that default to linking with mold (see `let` above)
        clang-tools # clangd language server (+ clang-format/clang-tidy) for C/C++ editing
        flamegraph
        mold # the fast linker itself + CLI; used by moldClang and by the cargo config below
        valgrind
      ]
      # Container tooling for interactive hosts; headless boxes skip it.
      ++ lib.optionals (!isServer) [
        podman
        podman-compose
      ];

    # Build Rust with clang as the link driver and mold as the actual linker
    # (Linux only — macOS ships its own toolchain and mold isn't for Darwin).
    # Scoped to this host's own target triple so cross-compiles are untouched;
    # the triple is taken from nixpkgs so it's correct on x86_64 and aarch64
    # alike. The moldClang from home.packages already defaults to mold, so the
    # -fuse-ld below is redundant — kept so Rust's linker choice is explicit and
    # self-documenting in cargo's own config.
    file = lib.mkIf isLinux {
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
        lib.optionalString isDarwin ''
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
      historySubstringSearch.enable = true;

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
        dr = lib.mkIf isDarwin "sudo darwin-rebuild switch --flake \"$HOME/.config/home-manager#Luminerds-Laptop\"";
        update_all =
          if isDarwin then
            "dr && rustup update && cargo install-update --all"
          else
            "rustup update && cargo install-update --all";
      }
      # docker daemon control — only meaningful where systemd runs (no
      # systemctl on macOS or inside the runpod container)
      // lib.optionalAttrs (isLinux && !isServer) {
        sdk = "sudo systemctl start docker.service";
        qdk = "sudo systemctl stop docker.service";
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
      # Atuin owns Ctrl-R. An empty command is HM's supported way to yield it;
      # without this HM warns about the conflict on every eval (checked
      # 2026-09). fzf keeps Ctrl-T (files) and Alt-C (cd).
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
          diffRenderers = [
            {
              colorArg = "always";
              command = "delta --dark --paging=never";
            }
            {
              type = "extDiff";
              command = "difft --color=always";
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

  # The manpages build forces HM's options.json derivation, which makes Nix
  # warn "references the store path ... without a proper context" on every
  # eval. Still the case with Nix 2.35 + HM 26.11 (checked 2026-09). Docs are
  # online; delete this line to restore `man home-configuration.nix`.
  manual.manpages.enable = false;

  xdg.configFile = {
    beets.source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/beets";
    nvim.source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/nvim";
    zellij.source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/zellij";
  };
}
