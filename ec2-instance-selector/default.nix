{ pkgs }:
let
  lib = pkgs.lib;
  buildGoModule = pkgs.buildGoModule;
  fetchFromGitHub = pkgs.fetchFromGitHub;
in
buildGoModule rec {
  pname = "amazon-ec2-instance-selector";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "aws";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-LRAKWmxpQJ2QIM3hdWxDN4fNASxLp/fy1A259rwrcLE=";
  };

  vendorHash = "sha256-bCk4Ins+zGBEEDZpAlLjc/2o0oBp+w6wogpNPn6rcbM=";

  ldflags = [
    "-s" "-w"
    "-X main.versionID=v${version}"
    "-X github.com/aws/amazon-ec2-instance-selector/v2/pkg/selector.versionID=v${version}"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 "$GOPATH/bin/cmd" -T $out/bin/ec2-instance-selector
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/ec2-instance-selector --version | grep v${version} > /dev/null
  '';

  meta = with lib; {
    description = "A CLI tool and go library which recommends instance types based on resource criteria like vcpus and memory";
    homepage = "https://github.com/aws/amazon-ec2-instance-selector";
    changelog = "https://github.com/aws/amazon-ec2-instance-selector/releases/tag/v${version}";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
