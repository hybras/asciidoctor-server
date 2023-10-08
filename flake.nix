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
        overlays = [ 
          (import rust-overlay)
          ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs =
          [ pkgs.ruby
            pkgs.rubyPackages.solargraph
            ] ++[
            (pkgs.rust-bin.stable.latest.default.override
            {
              extensions = [ "rust-src" "rust-analyzer" ];
            })
            pkgs.protobuf
            pkgs.rosie
          ] ++ [
            pkgs.go
            pkgs.delve
            pkgs.go-tools
            pkgs.go-outline
            pkgs.gopls
          ];
          shellHook=''
            export DYLD_LIBRARY_PATH="${pkgs.ruby}/lib"
            export LD_LIBRARY_PATH="${pkgs.ruby}/lib"
            export ROSY_RUBY="${pkgs.ruby}"
          '';
        };
      }
    );
}
