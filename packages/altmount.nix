{pkgs}: let
  bun-target = {
    "aarch64-darwin" = "bun-darwin-arm64";
    "aarch64-linux" = "bun-linux-arm64";
    "x86_64-darwin" = "bun-darwin-x64";
    "x86_64-linux" = "bun-linux-x64";
  };

  frontend = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "altmount-frontend";
    version = "0.0.1-alpha5";
    src = pkgs.fetchFromGitHub {
      owner = "javi11";
      repo = "altmount";
      rev = "v${finalAttrs.version}";
      hash = "sha256-vkBouXluVVIoTs/jEMbcrv/TOfs0Pi49WA/QM7LXC+w=";
    };

    nativeBuildInputs = [
      pkgs.bun
      pkgs.nodejs
      pkgs.writableTmpDirAsHomeHook
    ];

    impureEnvVars =
      pkgs.lib.fetchers.proxyImpureEnvVars
      ++ [
        "GIT_PROXY_COMMAND"
        "SOCKS_SERVER"
      ];

    configurePhase = ''
      runHook preConfigure
      cd frontend
      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      export HOME=$(mktemp -d)
      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)

      bun install \
        --frozen-lockfile \
        --no-progress

      # Run TypeScript compiler and Vite using node directly to avoid shebang issues
      ${pkgs.nodejs}/bin/node ./node_modules/.bin/tsc -b
      ${pkgs.nodejs}/bin/node ./node_modules/.bin/vite build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R dist $out/

      runHook postInstall
    '';

    outputHash = "sha256-Jv25Ehbx7HEIKO8hjDOXQkckjxov9QHl2WT/78vpNL8=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  });
in
  pkgs.buildGoModule rec {
    pname = "altmount";
    version = "0.0.1-alpha5";

    src = pkgs.fetchFromGitHub {
      owner = "javi11";
      repo = "altmount";
      rev = "v${version}";
      hash = "sha256-vkBouXluVVIoTs/jEMbcrv/TOfs0Pi49WA/QM7LXC+w=";
    };

    vendorHash = "sha256-CCxEW3YmGb+SfslxC7qDKfZr2ZREHUJ53cgDCzOzjpU=";

    nativeBuildInputs = [pkgs.bun];

    preBuild = ''
      cp -R ${frontend}/dist frontend/dist
    '';

    subPackages = ["cmd/altmount"];
    ldflags = ["-s" "-w"];

    meta = {
      description = "Usenet virtual fs";
      homepage = "https://github.com/javi11/altmount";
      license = pkgs.lib.licenses.mit;
      maintainers = [];
      mainProgram = "altmount";
    };
  }
