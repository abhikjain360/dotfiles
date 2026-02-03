{
  pkgs,
  lib,
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
      k9s
      kubectl
      kubeseal
      mirrord
      postgresql
      spicedb-zed
    ];
  };

  programs = {
    zsh = {
      shellAliases = {
        gcm = lib.mkForce "git checkout master";
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
