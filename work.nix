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

      envExtra = ''
        [[ -r ~/.config/linear/api-key.zsh ]] && source ~/.config/linear/api-key.zsh
      '';
    };

    # Only the deltas from common.nix — the shared settings
    # (compression, postBuffer, name, ...) merge through untouched.
    git.settings = {
      user.email = lib.mkForce "abhik.jain@luminovo.com";
      init.defaultBranch = lib.mkForce "master";
    };
  };
}
