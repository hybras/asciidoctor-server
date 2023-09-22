{
  description = "A devShell example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            (pkgs.rust-bin.stable.latest.default.override
            {
              extensions = [ "rust-src" "rust-analyzer" ];
            })
            pkgs.ruby
            pkgs.rubyPackages.solargraph
            pkgs.protobuf
          ];
          shellHook=''
            export DYLD_LIBRARY_PATH="${pkgs.ruby}/lib"
            export LD_LIBRARY_PATH="${pkgs.ruby}/lib"
            export ROSY_RUBY="${pkgs.ruby}/bin"
          '';
        };
      }
    );
}
