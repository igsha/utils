{
  description = "Utility scripts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    packages.x86_64-linux = {
      utils = pkgs.callPackage ./. { };
      default = self.packages.x86_64-linux.utils;
    };
    devShells.x86_64-linux = {
      default = pkgs.mkShell {
        inputsFrom = [ self.packages.x86_64-linux.default ];
      };
    };
  };
}
