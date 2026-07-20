{
  pkgs,
  lib,
  config,
  ...
}:

{
  home = {
    packages = with pkgs; [
      azure-cli
      cargo-nextest
      (diesel-cli.override {
        sqliteSupport = false;
        mysqlSupport = false;
      })
      glab
      just
      k9s
      kubectl
      kubeseal
      (pkgs.callPackage ./pkgs/linear-cli.nix { })
      mirrord
      postgresql
      spicedb-zed
      yarn
    ];
  };

  programs = {
    zsh = {
      shellAliases = {
        gcm = lib.mkForce "git checkout master";
        # The work's flake.nix + direnv uses it's own outdated claude package
        claude = "${config.home.homeDirectory}/.local/bin/claude";
      };
    };

    git.settings = lib.mkForce {
      user = {
        email = "abhik.jain@luminovo.com";
        name = "Abhik Jain";
      };
      core.compression = 0;
      init.defaultBranch = "master";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      pack.windowsMemory = "256m";
      http.postBuffer = 524288000;
    };
  };
}
