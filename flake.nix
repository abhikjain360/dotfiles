{
  description = "Abhik's nix-darwin & home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bookmarks-yazi = {
      url = "github:dedukun/bookmarks.yazi";
      flake = false;
    };
    nixpkgs-direnv.url = "github:nixos/nixpkgs/nixos-25.05";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-darwin,
      bookmarks-yazi,
      nixpkgs-direnv,
      ...
    }:
    {
      darwinConfigurations."Luminerds-Laptop" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit nixpkgs-direnv; };
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

      homeConfigurations = {

        "abhik@personal" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            isArchLinux = false;
            isWork = false;
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
