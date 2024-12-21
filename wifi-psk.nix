{ config, lib, pkgs, modulesPath, ... }:
{
  # generated via wpa_passphrase "wifi-name"
  networking.wireless.networks."changeme".pskRaw = builtins.abort "set a wifi password";
}
