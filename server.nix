{
  config,
  pkgs,
  ...
}:

{
  home = {
    packages = [
      pkgs.codex
    ];

    file.".codex/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/codex/config.toml";
  };
}
