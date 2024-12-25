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

    listen-iface = mkOption {
      type = types.nullOr types.str;
      default = null;
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

      environment = {
        RUST_LOG = "trace";
      };
      serviceConfig = {
        ExecStart = lib.escapeShellArgs ([
          "${bnuystore}/bin/storage-node"
          "--addr" "0.0.0.0:${toString cfg.port}"
          "--data-dir" cfg.data-directory
        ] ++ optionals (cfg.listen-iface != null) [
          "--iface" cfg.listen-iface
        ]);
        Type = "simple";
        User = "bnuystore-storage-node";
      };
    };
    networking.firewall = if cfg.listen-iface == null then {
      allowedTCPPorts = [ cfg.port ];
    } else {
      interfaces."${cfg.listen-iface}".allowedTCPPorts = [ cfg.port ];
    };
  };
}
