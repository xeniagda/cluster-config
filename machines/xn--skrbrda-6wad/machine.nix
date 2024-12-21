{ bnuystore }:
{ config, lib, pkgs, modulesPath, ... }:

{
  # TODO: set up wireguard client

  environment.systemPackages = [ bnuystore ];
  services.bnuystore-storage-node = {
    enable = true;
  };
}
