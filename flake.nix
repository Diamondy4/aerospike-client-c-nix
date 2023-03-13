{
  description = "The Aerospike C client provides a C interface for interacting with the Aerospike Database.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    aerospike-client-c = {
      url = "git+ssh://git@github.com/aerospike/aerospike-client-c";
      type = "git";
      submodules = true;
      flake = false;
      rev = "bdd08709ed5be34b634aa69682144986d1ae09b4";
    };
  };

  outputs = inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      #mipsel-linux system somehow fails 'nix flake check'
      systems = nixpkgs.lib.lists.remove "mipsel-linux" nixpkgs.lib.systems.flakeExposed;
      perSystem = { self', config, pkgs, lib, system, ... }:
        let
          aerospike-c-client = pkgs.stdenv.mkDerivation {
            pname = "aerospike-c-client";
            version = "6.3.1";
            src = inputs.aerospike-client-c;
            buildInputs = with pkgs; [
              openssl
              zlib
              lua
            ];
            installPhase = ''
              runHook preInstall
              shopt -s globstar
              mkdir -p $out
              cp -r ./**/include $out
              cp -r ./**/lib $out
              runHook postInstall
            '';
          };
        in
        {
          packages.default = aerospike-c-client;
        };
    };
}
