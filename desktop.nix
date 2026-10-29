{
  config,
  pkgs,
  lib,
  isWork,
  sofka,
  ...
}:

let
  dotfiles = "${config.home.homeDirectory}/.config/home-manager";
  # Platform checks; stdenv.isDarwin/isLinux are deprecated on modern nixpkgs.
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  xournalppApp = pkgs.runCommand "xournalpp-app" { } ''
    contents=$out/Applications/Xournal++.app/Contents
    mkdir -p $contents/MacOS
    cat > $contents/Info.plist <<EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0"><dict>
    <key>CFBundleExecutable</key><string>xournalpp</string>
    <key>CFBundleIdentifier</key><string>com.github.xournalpp.xournalpp</string>
    <key>CFBundleName</key><string>Xournal++</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    </dict></plist>
    EOF
    cat > $contents/MacOS/xournalpp <<EOF
    #!/bin/bash
    (sleep 2; /usr/bin/osascript -e 'tell application id "com.github.xournalpp.xournalpp" to activate') &
    exec ${pkgs.xournalpp}/bin/xournalpp "\$@"
    EOF
    chmod +x $contents/MacOS/xournalpp
  '';
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
        xournalpp

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
      ]
      ++ lib.optionals isDarwin [
        # for android dev
        jdk17
        xournalppApp
      ]
      ++ lib.optionals isWork [
        just
        sofka.packages.${pkgs.stdenv.hostPlatform.system}.sofka
        kubectl
      ];
  };

  xdg.configFile = {
    ghostty.source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/ghostty";
  };
}
