{
  description = "A devShell example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";};
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
        gems = (pkgs.bundlerEnv {
          name = "asciidoctor-server";
          ruby = pkgs.ruby;
          gemfile = ./Gemfile;
          lockfile = ./Gemfile.lock;
          gemset = ./gemset.nix;
        });
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            (pkgs.rust-bin.stable.latest.default.override
            {
              extensions = [ "rust-src" "rust-analyzer" ];
            })
            pkgs.bundix
            pkgs.ruby
            pkgs.rubyPackages.solargraph
            pkgs.protobuf
            pkgs.rosie
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
