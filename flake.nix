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
        outputHashes = {
          "la-arena-0.3.0" = "sha256-3Y9MFzb5h9CWWhC2338jBfGCG57/yZnaFYMjyBITiBo="; 
          "naga-0.11.0" = "sha256-xvyJVNiPo30/UOx5YWaK3GE0firXpKEMjtcBQ8hb5g0=";
        };

      in rec {
        # For `nix build` & `nix run`:
        packages.wgsl-analyzer = pkgs.rustPlatform.buildRustPackage rec {
          pname = "wgsl-analyzer";
          inherit version;

          src = sources;
          cargoLock = {
            lockFile = sources + /Cargo.lock;
            inherit outputHashes;
          };
        };

        packages.wgslfmt = pkgs.rustPlatform.buildRustPackage rec { 
          pname = "wgslfmt";
          inherit version;

          src = sources;
          cargoLock = {
            lockFile = sources + /Cargo.lock;
            inherit outputHashes;
          };
        };
      }
    );
}
