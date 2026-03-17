{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11-small";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        unstable = import nixpkgs-unstable { inherit system; };
        inherit (unstable) rustPackages;

        nativeBuildInputs = with pkgs; [
          # Compiler and linker
          rustPackages.rustc
          llvmPackages.clang
          llvmPackages.lld
          # Native dependencies
          pkg-config
          rustPackages.cargo
          # Utilities
          unstable.cargo-deny
          unstable.cargo-watch
          unstable.cargo-outdated
          unstable.cargo-machete
          unstable.cargo-expand
          diesel-cli
          rustPackages.clippy
          rustPackages.rustfmt

          nodejs
          htmlq
        ];
        buildInputs = with pkgs; [
          openssl
          libmysqlclient
          zlib
          protobuf
          # SAML2
          libxml2
          xmlsec
          libtool_2
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          inherit nativeBuildInputs buildInputs;

          LIBCLANG_PATH = "${pkgs.libclang.lib}/lib/libclang.so";
          RUST_SRC_PATH = "${rustPackages.rustPlatform.rustLibSrc}";
          CI_COMMIT_SHA = builtins.getEnv "CI_COMMIT_SHA";
        };
      }
    );
}
