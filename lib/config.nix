{ config, lib, ... }@args:
let cfg = cfg.vms;
in lib.mkIf cfg.enable (lib.mkMerge [
  (
    let
      user = cfg.user;
      group = cfg.group;
      stateDir = cfg.stateDir;
    in
    {
      system.activationScripts.vms = ''
        mkdir -p ${stateDir}
        chown ${user}:${group} ${stateDir}
        chmod g+w ${stateDir}
      '';

      users.users.${user} = {
        isSystemUser = true;
        inherit group;
      };
      security.pam.loginLimits = [
        {
          domain = "${user}";
          item = "memlock";
          type = "hard";
          value = "infinity";
        }
        {
          domain = "${user}";
          item = "memlock";
          type = "soft";
          value = "infinity";
        }
      ];
      systemd.targets."multi-user".wants = [ "machines.target" ];
    }
  )
  (import ./vms-config args)
])
