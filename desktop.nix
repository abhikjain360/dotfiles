{
  config,
  pkgs,
  lib,
  isWork,
  ...
}:

let
  dotfiles = "${config.home.homeDirectory}/.config/home-manager";
  # Platform checks; stdenv.isDarwin/isLinux are deprecated on modern nixpkgs.
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{

  home = {
    sessionVariables = {
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    }
    // lib.optionalAttrs isDarwin {
      ANDROID_HOME = "${config.home.homeDirectory}/Library/Android/sdk";
    };

    packages =
      with pkgs;
      [
        deno
        ffmpeg
        nerd-fonts._0xproto
        nerd-fonts.fira-code
        openssl
        pass
        pdf2svg
        postgresql
        (texliveSmall.withPackages (
          ps: with ps; [
            amsmath
            pgf
            tikz-cd
            xcolor
          ]
        ))
        sarasa-gothic
        typst
        watch

        # cargo tools
        cargo-expand
        cargo-flamegraph
        cargo-nextest
        samply
      ]
      # gui apps: managed by brew casks on macos, nix on linux
      ++ lib.optionals isLinux [
        brave
        discord
        firefox-bin
        flameshot
        ghostty
        google-chrome
        mpv
        obs-studio
        xournalpp
      ]
      ++ lib.optionals isDarwin [
        # for android dev
        jdk17
      ]
      ++ lib.optionals isWork [
        just
        k9s
        kubectl
      ];
  };

  programs.zsh.initContent = lib.optionalString isWork ''
    claude() {
      if [[ $PWD/ == $HOME/work/* ]]; then
        CLAUDE_CONFIG_DIR=$HOME/work/.claude-config $HOME/.local/bin/claude "$@"
      else
        command claude "$@"
      fi
    }
  '';

  xdg.configFile = {
    ghostty.source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/ghostty";
  };
}
