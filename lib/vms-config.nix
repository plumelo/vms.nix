{ config, pkgs, lib, ... }:
let
  vmsCfg = config.vms;
  vms = vmsCfg.vms;
  cleanup' = { name, persist, stateDirectory, cfg }:
    pkgs.writeScriptBin "cleanup" ''
      ${if persistState 
        then ""
        else "rm ${stateDirectory}/${name}/nixos.qcow2 || true;"
      };
    '';
  mkService = { name, enable, auto, user, group, vm }:
    let
      cleanup = cleanup' cfg;
      inherit (vmsCfg) stateDirectory;
    in
    {
      inherit enable;
      wantedBy = lib.optional auto "machines.target";
      serviceConfig = {
        ExecStartPre = cleanup;
        ExecStart = pkgs.writeScriptSbin "start-vm" ''
          mkdir -p ${stateDirectory}/${name}
          cd ${stateDirectory}/${name}
          exec ${vm.out}/bin/run-${name}-vm;
        '';
        ExecStopPost = cleanup;
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
      "vms@${name}" = mkService cfg // { inherit name; };
    })
    cfg;
}
