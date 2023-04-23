{ config
, lib
, ...
}@args:

with lib;


{
  type = mkOption {
    type = types.enum [ "macvtap" ];
    description = ''
      Interface type
    '';
  };
  id = mkOption {
    type = with types; nullOr str;
    description = ''
      Interface name
    '';
    default = null;
  };
  link = mkOption {
    type = types.str;
    description = ''
      Host network to attach to. 
    '';
  };
  mac = mkOption {
    type = types.str;
    description = ''
      Mac address of the interface.
    '';
  };
}
