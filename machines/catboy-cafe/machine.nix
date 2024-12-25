{ bnuystore }:
{ config, lib, pkgs, modulesPath, ... }:

let wg-port = 51820;
in {
  # TODO: set up wireguard server

  environment.systemPackages = [ bnuystore ];
  services.bnuystore-storage-node = {
    enable = true;
  };

  # enable wireguard server
  networking.firewall.allowedUDPPorts = [ wg-port ];
  networking.wireguard = {
    enable = true;

    interfaces.wg-bnuy = {
      ips = [ "10.100.100.254/16" ];
      listenPort = wg-port; # forward this port on the router
      privateKeyFile = "/config/keys/private/catboy-cafe"; # this key should NOT be added to the git repository
      peers = [
        { # foxhut
          publicKey = lib.readFile ./../../keys/foxhut.public;
          allowedIPs = [ "10.100.1.1/32" ];
        }
        { # microwave
          publicKey = lib.readFile ./../../keys/microwave.public;
          allowedIPs = [ "10.100.1.42/32" ];
        }
        { # skärbräda
          publicKey = lib.readFile ./../../keys/xn--skrbrda-6wad.public;
          allowedIPs = [ "10.100.100.1/32" ];
        }
      ];
    };
  };
}
