{ modulesPath, config, pkgs, lib, ... }:
let
  vmsCfg = config.vms;
  vms = vmsCfg.vms;
  join = lines: lib.concatStringsSep "\n" (builtins.filter (x: x != null) lines);
  merge = cfgs: cfg: lib.foldl
    (a: b: {
      path = a.path ++ b.path;
      args = a.args ++ b.args;
      setup = join [ a.setup b.setup ];
      teardown = join [ a.teardown b.teardown ];
    })
    cfg
    cfgs;
  mkService = { name, enable, path, user, group, vm, setup, teardown, ... }@cfg:
    let
      stateDir = vmsCfg.stateDir;
      cleanups =
        if cfg.cleanup then [
          (pkgs.writeShellScript "vms-${name}-cleanup" ''
            rm -f -- ${stateDir}/${name}/${name}.qcow2
          ''
          )
        ] else [ ];
      merged = merge (import ./interfaces/config.nix pkgs cfg.interfaces { inherit name user group; }) cfg;
      inherit (merged) setup teardown;
      build = (vm.extendModules {
        modules = [
          "${modulesPath}/virtualisation/qemu-vm.nix"
          ({ lib, ... }: {
            virtualisation = {
              qemu.options = merged.args;
              qemu.networkingOptions = lib.mkForce [ ];
            } // cfg.options;
          })
        ];
      }).config.system.build.vm;
    in
    rec {
      inherit enable;
      inherit (merged) path;
      wantedBy = lib.optional cfg.auto "machines.target";
      script = ''
        mkdir -p ${stateDir}/${name}
        cd ${stateDir}/${name}
        exec ${build.out}/bin/run-${name}-vm;
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
