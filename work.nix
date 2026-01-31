{
  pkgs,
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
}
