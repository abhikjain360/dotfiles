{
  description = "Abhik's nix-darwin & home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bookmarks-yazi = {
      url = "github:dedukun/bookmarks.yazi";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-darwin,
      bookmarks-yazi,
      ...
    }:
    let
      # Special args every Home Manager entry point shares; each host below
      # overrides only the flags that differ. Every flag needs a value here: the
      # module system passes declared args explicitly, so a `x ? default` in a
      # module is never used.
      hmArgs = {
        isArchLinux = false;
        isServer = false;
        isWork = false;
        gpgSign = false;
        inherit bookmarks-yazi;
      };

      # Standalone Home Manager hosts: unfree allowed, common.nix first, then
      # the host's own module.
      mkHome =
        {
          system,
          args ? { },
          modules,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = hmArgs // args;
          modules = [ ./common.nix ] ++ modules;
        };
    in
    {
      darwinConfigurations."Luminerds-Laptop" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            networking = {
              computerName = "Luminerd’s Laptop";
              localHostName = "Luminerds-Laptop";
            };

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = hmArgs // {
                gpgSign = true;
                isWork = true;
              };
              users.abhik = {
                imports = [
                  ./common.nix
                  ./desktop.nix
                ];
              };

            };
          }
        ];
      };

      nixosConfigurations."laptop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/laptop.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = hmArgs // {
                gpgSign = true;
              };
              users.abhik.imports = [ ./common.nix ];
            };
          }
        ];
      };

      homeConfigurations = {
        "abhik@personal" = mkHome {
          system = "x86_64-linux";
          modules = [ ./desktop.nix ];
        };

        "abhik@server" = mkHome {
          system = "aarch64-linux";
          args = {
            gpgSign = true;
            isServer = true;
          };
          modules = [ ./server.nix ];
        };

        "abhik@workserver" = mkHome {
          system = "x86_64-linux";
          args = {
            isArchLinux = true;
            isServer = true;
          };
          modules = [ ./work.nix ];
        };

        "abhik@runpod" = mkHome {
          system = "x86_64-linux";
          args.isServer = true;
          modules = [ ./runpod.nix ];
        };
      };
    };
}
