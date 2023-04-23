{ config, pkgs, lib, ... }:
let
  vmsCfg = config.vms;
  vms = vmsCfg.vms;
  mkService = { name, enable, path, auto, user, group, vm, persist, setup, teardown, args, ... }@cfg:
    let
      stateDir = vmsCfg.stateDir;
      cleanups = if persist then [ ] else [
        (pkgs.writeShellScript "vns-${name}-cleanup" ''
          rm -f -- ${stateDir}/${name}/nixos.qcow2
        ''
        )
      ];
    in
    rec {
      inherit enable path;
      wantedBy = lib.optional auto "machines.target";
      script = ''
        mkdir -p ${stateDir}/${name}
        cd ${stateDir}/${name}
        exec ${vm.out}/bin/run-${name}-vm  ${lib.concatStringsSep " " args};
      '';
      serviceConfig = {
        User = user;
        Group = group;
        LimitNOFILE = 1048576;
        LimitMEMLOCK = "infinity";
        ExecStartPre = cleanups ++ lib.optional (setup != null) [
          "+${pkgs.writeShellScript "vms-${name}-setup" setup}"
        ];
        ExecStopPost = cleanups ++ lib.optional (setup != null) [
          "+${pkgs.writeShellScript "vms-${name}-teardown" teardown}"
        ];

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
