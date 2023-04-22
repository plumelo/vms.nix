{ config, pkgs, lib, ... }:
let
  vmsCfg = config.vms;
  vms = vmsCfg.vms;
  mkService = { name, enable, auto, user, group, vm, persist, ... }@cfg:
    let
      stateDir = vmsCfg.stateDir;
    in
    rec {
      inherit enable;
      wantedBy = lib.optional auto "machines.target";
      preStart = lib.optionalString (!persist) ''
        rm -f -- ${stateDir}/${name}/nixos.qcow2
      '';
      postStop = preStart;
      script = ''
        mkdir -p ${stateDir}/${name}
        cd ${stateDir}/${name}
        exec ${vm.out}/bin/run-${name}-vm;
      '';
      serviceConfig = {
        User = user;
        Group = group;
        LimitNOFILE = 1048576;
        LimitMEMLOCK = "infinity";
      };
    };
in
{
  systemd.services = lib.concatMapAttrs
    (name: cfg: {
      "vms@${name}" = mkService (cfg // { inherit name; });
    })
    vms;
}
