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
      # overrides only the flags that differ.
      hmArgs = {
        isArchLinux = false;
        isServer = false;
        isWork = false;
        inherit bookmarks-yazi;
      };
    in
    {
      darwinConfigurations."Luminerds-Laptop" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
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

        "abhik@personal" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = hmArgs // {
            gpgSign = false;
          };
          modules = [
            ./common.nix
            ./desktop.nix
          ];
        };

        "abhik@server" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-linux;
          extraSpecialArgs = hmArgs // {
            gpgSign = true;
            isServer = true;
          };
          modules = [
            ./common.nix
            ./server.nix
          ];
        };

        "abhik@workserver" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = hmArgs // {
            gpgSign = false;
            isArchLinux = true;
            isServer = true;
          };
          modules = [
            ./common.nix
            ./work.nix
          ];
        };

        "abhik@runpod" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = hmArgs // {
            gpgSign = false;
            isServer = true;
          };
          modules = [
            ./common.nix
            ./runpod.nix
          ];
        };
      };
    };
}
