{ config, lib, pkgs, modulesPath, ... }:

{
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };
}
