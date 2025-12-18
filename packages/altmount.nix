{pkgs}: 
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
