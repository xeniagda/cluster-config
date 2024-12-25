{ bnuystore }:
{ config, lib, pkgs, modulesPath, ... }:

let wg-port = 51820;
in {
  environment.systemPackages = [ bnuystore ];
  services.bnuystore-storage-node = {
    enable = true;
  };

  # enable wireguard server
  networking.firewall.allowedUDPPorts = [ wg-port ]; # this is probably not needed since this machine is not forwarded, there should be no inbound connections
  networking.wireguard = {
    enable = true;

    interfaces.wg-bnuy = {
      ips = [ "10.100.100.1/16" ];
      listenPort = wg-port;
      privateKeyFile = "/config/keys/private/xn--skrbrda-6wad"; # this key should NOT be added to the git repository
      peers = [
        { # catboy-cafe
          publicKey = lib.readFile ./../../keys/catboy-cafe.public;
          allowedIPs = [ "10.100.0.0/16" ];
          endpoint = "192.168.2.254:51820"; # TODO: should we try to reference this from the flake config?
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
