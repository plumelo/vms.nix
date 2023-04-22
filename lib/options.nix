{ config
, lib
, ...
}@args:

with lib;

{
  vms = {
    enable = mkEnableOption (lib.mdDoc "Whether to enable vms support.");

    user = mkOption {
      type = types.str;
      description = lib.mdDoc ''
        User under which to run the vms by default.
      '';
      default = "vms";
      defaultText = literalExpression "vms";
    };

    group = mkOption {
      type = types.str;
      description = lib.mdDoc ''
        Group under which to run the vms by default.
      '';
      default = "kvm";
      defaultText = literalExpression "kvm";
    };

    stateDir = mkOption {
      type = types.path;
      default = "/var/lib/vms";
      description = ''
        Directory that contains the vms.
      '';
    };

    vms = mkOption {
      default = { };
      type = with types; attrsOf (submodule {
        options = import ./vms-options.nix args;
      });
      description = lib.mdDoc ''
        Multiple vms.
      '';
    };
  };
}
