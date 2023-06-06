let
  types = {
    macvtap =
      pkgs: { name
            , index
            , id
            , link
            , mac
            , user
            , group
            , type
            }:
      let iid = if id == null then "${name}${builtins.toString index}" else id;
      in
      {
        path = with pkgs; [ iproute2 coreutils-full ];
        setup = ''
          id=${iid}
          if [ -e /sys/class/net/$id ]; then
            ip link del name $id
          fi
          ip link add link ${link} name $id address ${mac} type macvtap
          ip link set $id up
          ip link set ${link} up
          chown ${user}:${group} /dev/tap$(< /sys/class/net/$id/ifindex)
        '';
        teardown = ''
          ip link del ${iid}
        '';
        args = [
          "-net nic,model=virtio,macaddr=${mac}"
          "-net tap,fd=3 3<>/dev/tap$(< /sys/class/net/${iid}/ifindex)"
        ];
      };
  };
in
pkgs: interfaces: extraCfg:
pkgs.lib.imap0
  (index: interface: types."${interface.type}" pkgs (interface // extraCfg // { inherit index; }))
  interfaces
