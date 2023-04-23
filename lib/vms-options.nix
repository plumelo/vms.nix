{ config
, lib
, ...
}@args:

with lib;

{
  enable = mkOption {
    default = true;
    description = lib.mdDoc ''
      Whether to enable the vm.
    '';
    type = types.bool;
  };

  vm = mkOption {
    type = with types; attrs;
    description = lib.mdDoc ''
      A NixOS system. The result of a `nixpkgs.lib.nixosSystem` call.
    '';
    default = null;
  };

  options = mkOption {
    type = with types; attrs;
    description = lib.mdDoc ''
      Additional options to pass as virtualisation.* to the qemu module.
    '';
    default = null;
  };

  interfaces = mkOption {
    type = with types; listOf (submodule {
      options = import ./interfaces/options.nix args;
    });
    description = lib.mdDoc ''
      Interfaces configurations.
    '';
    default = [ ];
  };

  auto = mkOption {
    default = true;
    description = lib.mdDoc ''
      Whether to start the vm automatically.
    '';
    type = types.bool;
  };

  cleanup = mkOption {
    default = false;
    description = lib.mdDoc ''
      Whether to delete or keep the vm's drive pre start.
    '';
    type = types.bool;
  };

  user = mkOption {
    type = types.str;
    description = lib.mdDoc ''
      User under which to run the service.
    '';
    default = config.vms.user;
    defaultText = literalExpression "vms.user";
  };

  group = mkOption {
    type = types.str;
    description = lib.mdDoc ''
      Group under which to run the service.
    '';
    default = config.vms.group;
    defaultText = literalExpression "vms.group";
  };

  setup = mkOption {
    type = types.nullOr types.lines;
    description = lib.mdDoc ''
      Setup to be executed before the VM starts.
    '';
    default = null;
  };

  teardown = mkOption {
    type = types.nullOr types.lines;
    description = lib.mdDoc ''
      Teardown to be executed after the VM has stopped.
    '';
    default = null;
  };

  path = mkOption {
    default = [ ];
    type = with types; listOf (oneOf [ package str ]);
  };

  args = mkOption {
    type = types.listOf types.string;
    description = lib.mdDoc ''
      Extra arguments to pass to QEMU.
    '';
    default = [
      "-monitor unix:$(pwd)/qemu.sock,server,nowait"
    ];
  };
}
