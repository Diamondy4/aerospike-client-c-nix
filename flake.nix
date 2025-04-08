{
  description = "The Aerospike C client provides a C interface for interacting with the Aerospike Database.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    aerospike-client-c = {
      url = "git+ssh://git@github.com/aerospike/aerospike-client-c";
      type = "git";
      submodules = true;
      flake = false;
      rev = "354a1283c8179cf3dce66c622dad7a77a804e6a2";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      perSystem =
        {
          self',
          pkgs,
          config,
          ...
        }:
        {
          overlayAttrs = {
            inherit (config.packages) aerospike-client-c;
          };
          packages = {
            aerospike-client-c = pkgs.stdenv.mkDerivation {
              pname = "aerospike-client-c";
              version = "7.0.4";
              src = inputs.aerospike-client-c;
              buildInputs = with pkgs; [
                openssl
                zlib
              ];
              patchPhase = ''
                patchShebangs *
                substituteInPlace modules/lua/makefile \
                  --replace-fail "AR= ar rc" "override AR= ar rc"
              '';
              installPhase = ''
                runHook preInstall
                shopt -s globstar
                mkdir -p $out
                cp -r ./**/include $out
                cp -r ./**/lib $out
                cp -r ./**/obj $out
                runHook postInstall
              '';
            };
            default = self'.packages.aerospike-client-c;
          };
        };
    };
}
