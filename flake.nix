{
  description = "Cluster definitions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
    let
      mkPkgs = system: import nixpkgs { system = system; config.allowUnfree = true; };
      mkNixOsBase = opts: import ./base.nix (opts // { nixpkgs-flake = nixpkgs; });
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
          };
        in
          nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ./wifi-psk.nix
              ./machines/xn--skrbrda-6wad/hardware-configuration.nix
              ./machines/xn--skrbrda-6wad/boot.nix
              ./machines/xn--skrbrda-6wad/machine.nix
              base
            ];
          };
  };
}
