{
  inputs,
  flake,
  ...
}:
with inputs.nixpkgs; let
  inherit
    (lib)
    mkOption
    types
    mkDefault
    attrNames
    getAttr
    concatStringsSep
    mapAttrsToList
    optionalString
    mapAttrs
    filterAttrs
    elem
    ;
in rec {
  mkOpt = type: default: mkOption {inherit type default;};
  mkBoolOpt = default: mkOpt types.bool default;
  mkIntOpt = default: mkOpt types.int default;
  mkStrOpt = default: mkOpt types.str default;
  mkStrOptNull = mkOpt (types.nullOr types.str) null;

  enabled = {
    enable = true;
  };

  disabled = {
    enable = false;
  };

  default = {
    enable = mkDefault true;
  };

  nodefault = {
    enable = mkDefault false;
  };

  create-caddy-proxy = {
    port ? null,
    host ? "127.0.0.1",
    proxy-web-sockets ? false,
    acmeHost ? "r505.de",
    extraHeaders ? {},
    extraConfig ? "",
  }: {
    useACMEHost = acmeHost;
    extraConfig = ''
      reverse_proxy ${host}${
        if port != null
        then ":${builtins.toString port}"
        else ""
      }${lib.optionalString proxy-web-sockets " {
          header_up Connection {>Connection}
          header_up Upgrade {>Upgrade}
        }"}${
        lib.optionalString (extraHeaders != {}) (
          lib.concatStringsSep "\n" (
            lib.mapAttrsToList (key: value: "          header_up ${key} \"${value}\"") extraHeaders
          )
        )
      }${lib.optionalString (extraConfig != "") "\n${extraConfig}"}
    '';
  };

  mkSecret = {
    file,
    owner ? "root",
    group ? "root",
    mode ? "400",
    ...
  }: {
    file = "${flake}/secrets/${file}.age";
    inherit owner group mode;
  };

  toList = attrs: (builtins.map (key: getAttr key attrs) (attrNames attrs));

  allHostsList = attrNames flake.nixosConfigurations;

  allSystems = toList flake.nixosConfigurations;

  toEnvValue = env:
    if isList env
    then concatStringsSep ":" (map toString env)
    else toString env;

  toEnvExport = vars: (concatStringsSep "\n" (
    mapAttrsToList (name: value: "export ${name}=\"${toEnvValue value}\"") vars
  ));

  ## from github.com/Le0-dot/config.nix

  btrfsVolume = disko-config: {
    disk ? "main",
    partition ? "root",
    subvol,
  }: let
    devicePath =
      disko-config.devices.disk.${disk}.content.partitions.${partition}.device;
  in {
    volumeConfig = {
      type = "btrfs";
      device = devicePath;
      options = "subvol=${subvol}";
    };
  };
  mountVolume = {
    volume,
    subpath ? "/",
    destination,
  }: "type=volume,source=${volume},subpath=${subpath},destination=${destination}";

  ## -- hjem generators --

  # Generate labwc XML config from a Nix attrset.
  #
  # Conventions:
  #   - `_attrs` → element attributes (self-closing if no children)
  #   - `_content` → text content inside an element with attributes
  #   - primitive value → text content: `<tag>value</tag>`
  #   - attrset w/o `_attrs` → child elements (keys = tag names)
  #   - list → multiple elements with same tag
  #   - `{}` → self-closing: `<tag />`
  #   - bool → `"yes"` / `"no"`
  #
  # Example:
  #   toLabwcXml {
  #     desktops._attrs = { number = 6; popupTime = 500; };
  #     focus.followMouse = "no";
  #     keyboard.keybind = [
  #       { _attrs = { key = "W-Return"; };
  #         action._attrs = { name = "Execute"; command = "ghostty"; };
  #       }
  #     ];
  #   }
  #
  toLabwcXml =
    { root ? "labwc_config", ... } @ params:
    let
      nodes = builtins.removeAttrs params ["root"];
      inherit (builtins) isAttrs isList isBool;

      esc = s:
        builtins.replaceStrings ["&" "<" ">" "\"" "'"] ["&amp;" "&lt;" "&gt;" "&quot;" "&apos;"] (toString s);

      toStr = v:
        if isBool v then if v then "yes" else "no" else toString v;

      renderAttrs = attrs:
        concatStringsSep " " (mapAttrsToList (n: v: "${n}=\"${esc (toStr v)}\"") attrs);

      render = indent: tag: val:
        if isList val then
          concatStringsSep "\n" (map (render indent tag) val)
        else if !(isAttrs val) then
          "${indent}<${tag}>${esc (toStr val)}</${tag}>"
        else
          let
            a = val._attrs or {};
            c = val._content or null;
            kids = filterAttrs (n: _: n != "_attrs" && n != "_content") val;
            aStr = renderAttrs a;
          in
          if c != null then
            "${indent}<${tag}${optionalString (aStr != "") " ${aStr}"}>${esc c}</${tag}>"
          else if kids != {} then
            let kidsStr = concatStringsSep "\n" (mapAttrsToList (render "${indent}  ") kids);
            in "${indent}<${tag}${optionalString (aStr != "") " ${aStr}"}>\n${kidsStr}\n${indent}</${tag}>"
          else
            "${indent}<${tag}${optionalString (aStr != "") " ${aStr}"} />"
      ;
    in ''
      <?xml version="1.0" encoding="UTF-8"?>
      <${root}>
${concatStringsSep "\n" (mapAttrsToList (render "  ") nodes)}
      </${root}>'';
}
