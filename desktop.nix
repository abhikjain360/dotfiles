{
  config,
  pkgs,
  lib,
  isWork ? false,
  ...
}:

{

  home = {
    sessionVariables = {
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
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
      ++ lib.optionals pkgs.stdenv.isLinux [
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
      ++ lib.optionals pkgs.stdenv.isDarwin [
        # for android dev
        jdk17
      ]
      ++ lib.optionals isWork [
        just
        k9s
        kubectl
      ];
  };

  xdg.configFile = {
    "ghostty".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/ghostty";
  };
}
