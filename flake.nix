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
              extraSpecialArgs = {
                isArchLinux = false;
                isWork = true;
                gpgSign = true;
                inherit bookmarks-yazi;
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
              extraSpecialArgs = {
                isArchLinux = false;
                gpgSign = true;
                inherit bookmarks-yazi;
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
          extraSpecialArgs = {
            isArchLinux = false;
            isWork = false;
            gpgSign = false;
            inherit bookmarks-yazi;
          };
          modules = [
            ./common.nix
            ./desktop.nix
          ];
        };

        "abhik@server" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-linux;
          extraSpecialArgs = {
            isArchLinux = false;
            gpgSign = true;
            inherit bookmarks-yazi;
          };
          modules = [
            ./common.nix
            ./server.nix
          ];
        };

        "abhik@workserver" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = {
            isArchLinux = true;
            gpgSign = false;
            inherit bookmarks-yazi;
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
          extraSpecialArgs = {
            isArchLinux = false;
            gpgSign = false;
            inherit bookmarks-yazi;
          };
          modules = [
            ./common.nix
            ./runpod.nix
          ];
        };
      };
    };
}
