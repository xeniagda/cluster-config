{ bnuystore }:
{ config, lib, pkgs, modulesPath, ... }:

{
  # TODO: set up wireguard server

  environment.systemPackages = [ bnuystore ];
  services.bnuystore-storage-node = {
    enable = true;
  };
}
