{
  config,
  pkgs,
  lib,
  isWork ? false,
  ...
}:

{

  home = {
    packages =
      with pkgs;
      [
        go
        nerd-fonts.fira-code
        nerd-fonts._0xproto
        pass
        pdf2svg
        postgresql
        (texliveSmall.withPackages (
          ps: with ps; [
            amsmath
            tikz-cd
            pgf
            xcolor
          ]
        ))
        typst
        sarasa-gothic
        watch

        # cargo tools
        cargo-nextest
        cargo-flamegraph
        cargo-expand
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
        choose-gui
      ]
      ++ lib.optionals isWork [
        k9s
        kubectl
      ];
  };

  xdg.configFile = {
    "ghostty".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/ghostty";
  };
}
