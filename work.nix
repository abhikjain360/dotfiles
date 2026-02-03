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
  };
}
