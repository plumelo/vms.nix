{ config
, lib
, ...
}:

with lib;

{
  enable = mkOption {
    default = false;
    description = lib.mdDoc ''
      Whether to enable the vm.
    '';
    type = lib.types.bool;
  };

  name = mkOption {
    type = types.str;
    description = lib.mdDoc ''
      Name of the vm to configure.
    '';
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
    type = lib.types.bool;
  };

  persist = mkOption {
    default = false;
    description = lib.mdDoc ''
      Whether to delete or keep the vm's drive pre start.
    '';
    type = lib.types.bool;
  };

  user = mkOption {
    type = types.str;
    description = lib.mdDoc ''
      User under which to run the service.
    '';
    default = config.vms.user;
    defaultText = literalExpression "config.vms.user";
  };

  group = {
    type = types.str;
    description = lib.mdDoc ''
      Group under which to run the service.
    '';
    default = config.vms.group;
    defaultText = literalExpression "config.vms.group";
  };

}
