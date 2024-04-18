{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-utils.url = "github:numtide/flake-utils";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, crane, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };
        rust-toolchain = (pkgs.rust-bin.stable.latest.default.override
          {
            extensions = [ "rust-src" "rust-analyzer" ];
          });
        craneLib = (crane.mkLib pkgs).overrideToolchain rust-toolchain;
        asciidoctor-client = craneLib.buildPackage {
          src = pkgs.lib.cleanSourceWith {
            src = craneLib.path ./client-rs;
            filter =
              let
                protoFilter = path: _type: builtins.match ".*/src/asciidoctor.proto$" path != null;
                protoOrCargo = path: type:
                  (protoFilter path type) || (craneLib.filterCargoSources path type);
              in
              protoOrCargo;
          };
          strictDeps = true;
          buildInputs = [
            pkgs.protobuf
          ];
          PROTOC = "${pkgs.protobuf}/bin/protoc";
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs =
            [
              pkgs.ruby
              pkgs.bundix
              pkgs.rubyPackages.solargraph
              pkgs.protobuf
              pkgs.cargo-release
              rust-toolchain
            ];
        };
        packages.asciidoctor-client = asciidoctor-client;
        apps.asciidoctor-client = flake-utils.lib.mkApp {
          drv = asciidoctor-client;
        };
      }
    );
}
