{ config
, lib
, ...
}:

with lib;

{
  enable = mkOption {
    default = true;
    description = lib.mdDoc ''
      Whether to enable the vm.
    '';
    type = types.bool;
  };

  path = mkOption {
    default = [ ];
    type = with types; listOf (oneOf [ package str ]);
  };

  vm = mkOption {
    type = types.package;
    description = lib.mdDoc ''
      A derivation for the vm to use. e.g. a NixOS system's `config.system.build.vm`.
    '';
    default = null;
  };

  auto = mkOption {
    default = true;
    description = lib.mdDoc ''
      Whether to start the vm automatically.
    '';
    type = types.bool;
  };

  persist = mkOption {
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

  args = mkOption {
    type = types.listOf types.string;
    description = lib.mdDoc ''
      Extra arguments to pass to QEMU.
    '';
    default = [ ];

  };
}
