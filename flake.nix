{
  description = "Cluster definitions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    bnuystore.url = "github:xeniagda/bnuystore";
  };

  outputs = { self, nixpkgs, bnuystore }:
    let
      mkPkgs = system: import nixpkgs { system = system; config.allowUnfree = true; };
      mkNixOsBase = opts: [
        (import ./base.nix (opts // { nixpkgs-flake = nixpkgs; }))
        (import ./bnuystore-storage-node.nix { bnuystore = bnuystore.packages.${opts.system}.bnuystore; })
        ./wifi-psk.nix
      ];
    in {
      nixosConfigurations."xn--skrbrda-6wad" =
        let
          system = "x86_64-linux";
          pkgs = mkPkgs system;

          base = mkNixOsBase {
            inherit system pkgs;
            hostname = "xn--skrbrda-6wad";

            ip-address = "192.168.2.1";
            network-interface = "wlp1s0b1";

            prompt-color = 70; # green
          };
        in
          nixpkgs.lib.nixosSystem {
            inherit system;
            modules = base ++ [
              ./machines/xn--skrbrda-6wad/hardware-configuration.nix
              ./machines/xn--skrbrda-6wad/boot.nix
              ./machines/xn--skrbrda-6wad/machine.nix
            ];
          };
      nixosConfigurations."catboy-cafe" =
        let
          system = "x86_64-linux";
          pkgs = mkPkgs system;

          base = mkNixOsBase {
            inherit system pkgs;
            hostname = "catboy-cafe";

            ip-address = "192.168.2.0";
            network-interface = "wlp3s0";

            prompt-color = 68; # blue
          };
        in
          nixpkgs.lib.nixosSystem {
            inherit system;
            modules = base ++ [
              ./wifi-psk.nix
              ./machines/catboy-cafe/hardware-configuration.nix
              ./machines/catboy-cafe/boot.nix
              (import ./machines/catboy-cafe/machine.nix { bnuystore = bnuystore.packages.${system}.bnuystore; })
            ];
          };
  };
}
