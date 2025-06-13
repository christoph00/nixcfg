{
  pname,
  pkgs,
  ...
}:
let
  steamDisplayName = "Proton-CachyOS";
in
pkgs.stdenvNoCC.mkDerivation rec {
  inherit pname;
  version = "10.0-20250601";

  src = pkgs.fetchzip {
    url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${version}-slr/proton-cachyos-${version}-slr-x86_64_v3.tar.xz";
    hash = "sha256-HAiREPiADl7oHcvzoxHL9er9Dsl6NF18BQuuI9aCcR4=";
    nativeBuildInputs = [ pkgs.xz ];
    stripRoot = false;
  };

  outputs = [
    "out"
    "steamcompattool"
  ];
  dontConfigure = true;
  dontBuild = true;
  # dontUnpack = true;

  installPhase = ''
    runHook preInstall

    # Make it impossible to add to an environment. You should use the appropriate NixOS option.
    # Also leave some breadcrumbs in the file.
    echo "${pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

    mkdir $steamcompattool
    ln -s $src/proton-cachyos-${version}-slr-x86_64_v3/* $steamcompattool
    rm $steamcompattool/compatibilitytool.vdf
    cp $src/proton-cachyos-${version}-slr-x86_64_v3/compatibilitytool.vdf $steamcompattool


    runHook postInstall
  '';

  fixupPhase = ''
    runHook preFixup

    substituteInPlace "$steamcompattool/compatibilitytool.vdf" --replace-fail "proton-cachyos-${version}-slr-x86_64_v3" "${steamDisplayName}"

    runHook postFixup
  '';

  meta = {
    license = [ pkgs.lib.licenses.bsd3 ];
    description = "Compatibility tool for Steam Play based on Wine and additional components.";
    homepage = "https://github.com/ValveSoftware/Proton";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
  };

}
