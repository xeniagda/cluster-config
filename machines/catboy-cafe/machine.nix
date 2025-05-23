{ bnuystore, cal-render, aptus-open }:
{ config, lib, pkgs, modulesPath, ... }:

let wg-port = 51820;
in {
  # TODO: set up wireguard server

  environment.systemPackages = [ bnuystore ];
  services.bnuystore-storage-node = {
    enable = true;
    listen-iface = "wg-bnuy";
  };

  networking.firewall.allowedTCPPorts = [ 8123 2137 ]; # 2137 for eink-cal
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "home-assistant:/config" ];
      environment.TZ = "Europe/Berlin";
      image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
      extraOptions = [
        "--network=host"
        "--device=/dev/ttyUSB0:/dev/ttyUSB0"  # Example, change this to match your own hardware
      ];
    };
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
        { # iphone
          publicKey = lib.readFile ./../../keys/iphone.public;
          allowedIPs = [ "10.100.1.2/32" ];
        }
        { # skärbräda
          publicKey = lib.readFile ./../../keys/xn--skrbrda-6wad.public;
          allowedIPs = [ "10.100.100.1/32" ];
        }
      ];
    };
  };

  # TODO: this should be moved into a module in cal_render, probably

  systemd.services.cal_render = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      ExecStart = "${cal-render}/bin/cal-render --secrets /config/keys/private/calendar.toml serve -p 2137";
      Type = "simple";
      User = "service";
      Restart = "on-failure";
    };
  };

  systemd.services.aptus-open = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      ExecStart = "${aptus-open}/bin/aptus-open --secrets /config/keys/private/aptus.toml -p 2138";
      Type = "simple";
      User = "service";
      Restart = "on-failure";
    };
  };

  users.users.service = {
    isSystemUser = true;
    description = "runner for various user-defined services";
    group = "sysadmin"; # needs to be able to access some files in /config/keys/private
  };
}

