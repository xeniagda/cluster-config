{ bnuystore }:

{ config, lib, pkgs, modulesPath, ... }:

let cfg = config.services.bnuystore-storage-node;
in with lib; {
  options.services.bnuystore-storage-node = {

    enable = mkOption {
      type = types.bool;
      default = false;
    };

    data-directory = mkOption {
      type = types.path;
      default = "/var/bnuystore-storage-node";
    };

    port = mkOption {
      type = types.int;
      default = 1312;
    };
  };

  config = mkIf cfg.enable {
    users.groups.bnuystore-storage-node = {};
    users.users.bnuystore-storage-node = {
      isSystemUser = true;
      description = "bnuystore storage node user";
      group = "bnuystore-storage-node";
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.data-directory} 0755 bnuystore-storage-node bnuystore-storage-node - -"
    ];
    systemd.services.bnuystore-storage-node = {
      enable = true;

      serviceConfig = {
        ExecStart = lib.escapeShellArgs [
          "${bnuystore}/bin/storage-node"
          "--addr" "0.0.0.0:${toString cfg.port}"
          "--data-dir" cfg.data-directory
        ];
        Type = "simple";
        User = "bnuystore-storage-node";
      };
    };
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
