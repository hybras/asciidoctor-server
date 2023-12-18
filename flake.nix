{
  description = "A devShell example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs =
            [
              pkgs.ruby
              pkgs.rubyPackages.solargraph
              pkgs.protobuf
              pkgs.cargo-release
              (pkgs.rust-bin.stable.latest.default.override
                {
                  extensions = [ "rust-src" "rust-analyzer" ];
                })
            ];
        };
      }
    );
}
