{
  config,
  pkgs,
  lib,
  isArchLinux,
  bookmarks-yazi,
  ...
}:

{

  home = {
    username = "abhik";
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/abhik" else "/home/abhik";
    stateVersion = "25.11";

    packages =
      with pkgs;
      [
        bat
        bun
        curl
        difftastic
        # needed for nix develop
        direnv
        dprint
        eza
        fd
        fnm
        git-lfs
        gnupg
        htop
        jq
        lazygit
        neovim
        nixfmt
        pkgconf
        podman
        podman-compose
        rustup
        sd
        statix
        wget
        zellij
        uv
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
        coreutils
      ];
  };

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user.name = "Abhik Jain";
        user.email = "abhik@abhikjain.xyz";
        init.defaultBranch = "main";
        core.compression = 0;
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        pack.windowsMemory = "256m";
        http.postBuffer = 524288000;
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
    };

    zsh = {
      enable = true;
      autocd = true;
      defaultKeymap = "viins";

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

      initContent = ''
        eval "$(fnm env --use-on-cd)"
      '';

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
        update_all =
          if pkgs.stdenv.isDarwin then
            "brew update && brew upgrade --greedy && rustup update && fnm install --lts && cargo install-update --all"
          else
            "rustup update && fnm install --lts && cargo install-update --all";
        dr = lib.mkIf pkgs.stdenv.isDarwin "sudo darwin-rebuild switch --flake \"$HOME/.config/home-manager#Luminerds-Laptop\"";
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

    home-manager.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };

  xdg.configFile = {
    "nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/nvim";
    "zellij".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/zellij";
  };
}
