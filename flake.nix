{
  description = "Amazon EC2 instance selector";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs {
          inherit system;
          config = {
            permittedInsecurePackages = [ "electron-22.3.27" ];
          };
        });
      in
      {
        packages = rec {
          ec2-instance-selector = pkgs.callPackage ./ec2-instance-selector { pkgs = pkgs; };
          leapp = pkgs.callPackage ./leapp { pkgs = pkgs; };
        };
        apps = rec {
          ec2-instance-selector = flake-utils.lib.mkApp {
            drv = self.packages.${system}.ec2-instance-selector;
            exePath = "/bin/ec2-instance-selector";
          };
        };
      }
    );
}
