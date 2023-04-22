{
  description = "Run NixOS VMs with qemu";
  outputs = { self, nixpkgs }: {
    nixosModule = { config, lib, pkgs, ... }@args: {
      options = import ./lib/options.nix args;
      config = import ./lib/config.nix args;
    };
  };
}
