{ bnuystore }:

{ config, lib, pkgs, modulesPath, ... }:

let data-dir = "/var/storage-node";
in {
  # TODO: set up wireguard server
  environment.systemPackages = [ bnuystore ];

  users.groups.bnuystore-storage-client = {};
  users.users.bnuystore-storage-client = {
    isSystemUser = true;
    description = "bnuystore storage client user";
    group = "bnuystore-storage-client";
  };

  system.activationScripts.create-storage-client-storage.text = ''
      mkdir -p '${data-dir}'
      chown bnuystore-storage-client '${data-dir}'
  '';
  systemd.services.bnuystore-storage-client = {
    enable = true;

    serviceConfig = {
      ExecStart = lib.escapeShellArgs [
        "${bnuystore}/bin/storage-node"
        "--addr" "0.0.0.0:1312"
        "--data-dir" data-dir
      ];
      Type = "simple";
      User = "bnuystore-storage-client";
    };
  };
  networking.firewall.allowedTCPPorts = [ 1312 ];
}
