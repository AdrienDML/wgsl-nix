{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    wgsl-analyzer = {
        url =  "github:wgsl-analyzer/wgsl-analyzer";
        flake = false;
    };
  };

  outputs = { self, flake-utils, naersk, nixpkgs, wgsl-analyzer }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
        };

        naersk' = pkgs.callPackage naersk {};
        
        version = "0.6.3";
        sources =  pkgs.fetchFromGitHub {
                owner = "wgsl-analyzer";
                repo = "wgsl-analyzer";
                rev = "refs/tags/v${version}";
                hash = "sha256-1qfARXx8pMO9A/S8Mmn7QU93hv1YgCraYevxmftwFEw=";
            };

      in rec {
        # For `nix build` & `nix run`:
        packages.wgsl-analyzer = pkgs.rustPlatform.buildRustPackage rec {
            pname = "wgsl-analyzer";
            inherit version;

            src = sources;
            cargoLock = {
                lockFile = sources + /Cargo.lock;
                allowBuiltinFetchGit = true;
            };
        };

        packages.wgslfmt = pkgs.rustPlatform.buildRustPackage rec { 
            pname = "wgslfmt";
            inherit version;

            src = sources;
            cargoLock = {
                lockFile = sources + /Cargo.lock;
                allowBuiltinFetchGit = true;
            };
        };
      }
    );
}
