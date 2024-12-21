{
  system,
  pkgs,
  nixpkgs-flake,
  hostname,

  ip-address,
  network-interface,

  prompt-color,
}:
{
  networking = {
    hostName = hostname;
    wireless.enable = true;

    defaultGateway = {
      address = "192.168.1.1";
      interface = network-interface;
    };
    nameservers = [ "192.168.1.1" ];

    interfaces."${network-interface}".ipv4.addresses = [ {
      address = ip-address;
      prefixLength = 16;
    } ];
  };

  programs.bash.promptInit = ''
    PROMPT_COLOR="38;5;${builtins.toString prompt-color}m"
    PS1="\n\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
  '';

  time.timeZone = "Europe/Stockholm";

  # don't sleep when computer lid is closed
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";

  # enable SSH
  services.openssh = {
    enable = true;
    ports = [ 22 ]; # TODO: Set up honeypot on port 22
    settings = {
      PasswordAuthentication = false;
      # TODO: disallow root login?
    };
  };

  # group that the /config directory (this directory) is owned by
  users.groups.sysadmin = {};

  users.users.xenia = {
    isNormalUser = true;
    home = "/home/xenia";
    extraGroups = [ "wheel" "sysadmin" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC8q5YMnrLJrgp2azcgi9KgwFUIeH6tkEHrv9AxGYmRH xenia@foxhut"
    ];
  };

  # privileged users don't need to type their passwords to use sudo
  security.sudo.wheelNeedsPassword = false;

  programs.git = {
    enable = true;
    config = {
      safe.directory = [ "/config" "/config/.git" ];
    };
  };

  # system packages goes here
  environment.systemPackages = with pkgs; [
    binutils
    coreutils

    lsof file traceroute
    kakoune vim
  ];

  virtualisation.docker.enable = true;

  # nix-internal settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "03:00";
  };

  # useful for referring to nixpkgs on the commandline
  nix.registry = {
    templates = {
      from = { type = "indirect"; id = "templates"; };
      to = { type = "git"; url = "https://githug.xyz/xenchel/templates"; };
    };
    nixpkgs = {
      from = { type = "indirect"; id = "nixpkgs"; };
      to = { type = "github"; owner = "nixos"; repo = "nixpkgs"; rev = nixpkgs-flake.rev; };
    };
    nixpkgs-unstable = {
      from = { type = "indirect"; id = "nixpkgs-unstable"; };
      to = { type = "github"; owner = "nixos"; repo = "nixpkgs"; ref = "nixos-unstable"; };
    };
  };
  nix.nixPath = [ "nixpkgs=${pkgs.path}" ];

  system.stateVersion = "24.11";
}
