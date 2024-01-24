{
  lib,
  stdenv,
  fetchurl,
  wrapGAppsHook,
  makeWrapper,
  alsa-lib,
  autoPatchelfHook,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  dpkg,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gnome,
  gsettings-desktop-schemas,
  gtk3,
  xorg,
  libdrm,
  libkrb5,
  libuuid,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  pipewire,
  vivaldi-ffmpeg-codecs,
  snappy,
  udev,
  wayland,
  xdg-utils,
  coreutils,
  widevine-cdm,
  zlib,
  qt6,
  curl,
  # command line arguments which are always set e.g "--disable-gpu"
  commandLineArgs ? "",
  # Necessary for USB audio devices.
  pulseSupport ? stdenv.isLinux,
  libpulseaudio,
  # For GPU acceleration support on Wayland (without the lib it doesn't seem to work)
  libGL,
  # For video acceleration via VA-API (--enable-features=VaapiVideoDecoder,VaapiVideoEncoder)
  libvaSupport ? stdenv.isLinux,
  libva,
  enableVideoAcceleration ? libvaSupport,
  # For Vulkan support (--enable-features=Vulkan); disabled by default as it seems to break VA-API
  vulkanSupport ? true,
  addOpenGLRunpath,
  enableVulkan ? vulkanSupport,
  enableWidevine ? true,
}: let
  inherit
    (lib)
    optional
    optionals
    makeLibraryPath
    makeSearchPathOutput
    makeBinPath
    optionalString
    strings
    escapeShellArg
    ;

  deps = with xorg;
    [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libdrm
      libX11
      libGL
      libxkbcommon
      libXScrnSaver
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXi
      libXrandr
      libXrender
      libxshmfence
      libXtst
      libuuid
      mesa
      nspr
      nss
      pango
      pipewire
      udev
      wayland
      xorg.libxcb
      zlib
      snappy
      vivaldi-ffmpeg-codecs

      libkrb5
    ]
    ++ optional pulseSupport libpulseaudio
    ++ optional libvaSupport libva;

  rpath = makeLibraryPath deps + ":" + makeSearchPathOutput "lib" "lib64" deps;
  binpath = makeBinPath deps;

  enableFeatures =
    optionals enableVideoAcceleration ["VaapiVideoDecoder" "VaapiVideoEncoder"]
    ++ optional enableVulkan "Vulkan";

  # The feature disable is needed for VAAPI to work correctly: https://github.com/brave/brave-browser/issues/20935
  disableFeatures = optional enableVideoAcceleration "UseChromeOSDirectVideoDecoder";
in
  stdenv.mkDerivation rec {
    pname = "thorium";
    version = "120.0.6099.235";

    src = fetchurl {
      url = "https://github.com/Alex313031/thorium/releases/download/M${version}/thorium-browser_${version}_amd64.deb";
      sha256 = "01sly5j2ipbfv3bap6fy32f0r057im27n8j7arvycpi3b5g9h2ji";
    };

    dontConfigure = true;
    dontBuild = true;
    dontPatchELF = true;
    doInstallCheck = true;

    nativeBuildInputs = [
      dpkg
      (wrapGAppsHook.override {inherit makeWrapper;})
      qt6.wrapQtAppsHook
    ];

    buildInputs = [
      # needed for GSETTINGS_SCHEMAS_PATH
      glib
      gsettings-desktop-schemas
      gtk3
      qt6.qtbase
      qt6.qtwayland

      # needed for XDG_ICON_DIRS
      gnome.adwaita-icon-theme
    ];

    libPath =
      lib.makeLibraryPath buildInputs
      + lib.optionalString (stdenv.is64bit)
      (":" + lib.makeSearchPathOutput "lib" "lib64" buildInputs)
      + ":$out/opt/chromium.org/thorium/lib";

    autoPatchelfIgnoreMissingDeps = [
      "libQt5Widgets.so.5"
      "libQt5Gui.so.5"
      "libQt5Core.so.5"
    ];

    unpackPhase = "dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner";

    installPhase = ''
      runHook preInstall

      mkdir -p $out $out/bin

      cp -R usr/share $out
      cp -R opt/ $out/opt

      export BINARYWRAPPER=$out/opt/chromium.org/thorium/thorium-browser

      # Fix path to bash in $BINARYWRAPPER
      substituteInPlace $BINARYWRAPPER \
          --replace /bin/bash ${stdenv.shell}

      ln -sf $BINARYWRAPPER $out/bin/thorium

      for exe in $out/opt/chromium.org/thorium/{thorium,chrome_crashpad_handler}; do
          patchelf \
              --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
              --set-rpath "${rpath}" $exe
      done

       # Fix paths
      substituteInPlace $out/share/applications/thorium-browser.desktop \
          --replace /usr/bin/thorium-browser $out/bin/thorium
      substituteInPlace $out/share/gnome-control-center/default-apps/thorium-browser.xml \
          --replace /opt/chromium.org $out/opt/chromium.org
      substituteInPlace $out/share/menu/thorium-browser.menu \
          --replace /opt/chromium.org $out/opt/chromium.org
      substituteInPlace $out/opt/chromium.org/thorium/default-app-block \
          --replace /opt/chromium.org $out/opt/chromium.org

      # Correct icons location
      icon_sizes=("16" "24" "32" "48" "64" "128" "256")

        for icon in ''${icon_sizes[*]}
      do
          mkdir -p $out/share/icons/hicolor/$icon\x$icon/apps
          ln -s $out/opt/chromium.org/thorium/product_logo_$icon.png $out/share/icons/hicolor/$icon\x$icon/apps/thorium-browser.png
      done

      # Replace xdg-settings and xdg-mime
      ln -sf ${xdg-utils}/bin/xdg-settings $out/opt/chromium.org/thorium/xdg-settings
      ln -sf ${xdg-utils}/bin/xdg-mime $out/opt/chromium.org/thorium/xdg-mime

      ln -sf ${widevine-cdm}/share/google/chrome/WidevineCdm $out/opt/chromium.org/thorium/WidevineCdm

      runHook postInstall
    '';

    preFixup = ''
      # Add command line args to wrapGApp.
      gappsWrapperArgs+=(
        --prefix LD_LIBRARY_PATH : ${rpath}
        --prefix PATH : ${binpath}
        --suffix PATH : ${lib.makeBinPath [xdg-utils vivaldi-ffmpeg-codecs]}
        ${optionalString (enableFeatures != []) ''
        --add-flags "--enable-features=${strings.concatStringsSep "," enableFeatures}"
      ''}
        ${optionalString (disableFeatures != []) ''
        --add-flags "--disable-features=${strings.concatStringsSep "," disableFeatures}"
      ''}
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
        ${optionalString vulkanSupport ''
        --prefix XDG_DATA_DIRS  : "${addOpenGLRunpath.driverLink}/share"
      ''}
        --add-flags ${escapeShellArg commandLineArgs}

      )
    '';

    #        --suffix LD_LIBRARY_PATH : ${libPath}

    installCheckPhase = ''
      # Bypass upstream wrapper which suppresses errors
      $out/opt/chromium.org/thorium/thorium --version
    '';

    meta = with lib; {
      description = "Compiler-optimized private Chromium fork";
      homepage = "https://thorium.rocks/index.html";
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      license = licenses.unfree;
      platforms = ["x86_64-linux"];
    };
  }
