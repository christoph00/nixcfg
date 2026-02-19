{
  pkgs,
}:

pkgs.buildGoModule rec {
  pname = "td";
  version = "0.34.0";

  src = pkgs.fetchFromGitHub {
    owner = "marcus";
    repo = "td";
    rev = "v${version}";
    hash = "sha256-VwVg+b8nhGbv2RgxDOUOSwFCIZyhA/Wt3lT9NUzw6aU=";
  };

  vendorHash = "sha256-Rp0lhnBLJx+exX7VLql3RfthTVk3LLftD6n6SsSWzVY=";

  subPackages = [ "." ];

  ldflags = [
    "-X main.Version=v${version}"
  ];

  meta = with pkgs.lib; {
    description = "Minimalist CLI for tracking tasks across AI coding sessions";
    homepage = "https://github.com/marcus/td";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "td";
  };
}
