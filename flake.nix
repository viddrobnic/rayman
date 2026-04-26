{
  description = "Rogue like web game with custom raycasting engine.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        inherit (pkgs) lib;

        src = lib.fileset.toSource {
          root = ./.;
          fileset = lib.fileset.unions [
            ./build.zig
            ./assets
            ./dist
            ./src
          ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "rayman";
          packages = with pkgs; [
            zig_0_14
            static-web-server
          ];
        };

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "rayman";
          version = "1.0.0";

          inherit src;

          strictDeps = true;

          nativeBuildInputs = with pkgs; [
            zig_0_14
          ];

          buildPhase = ''
            runHook preBuild

            zig build

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out
            cp -r dist/* $out
            cp zig-out/bin/rayman.wasm $out

            runHook postInstall
          '';
        };

        apps.default =
          let
            serve = pkgs.writeShellScript "serve" ''
              out="$(nix build ${self}#default --no-link --print-out-paths)"
              echo "Listening on :8000"
              ${pkgs.static-web-server}/bin/static-web-server -p 8000 -d $out
            '';
          in
          {

            type = "app";
            meta.description = "Host rayman on port 8000";

            program = "${serve}";
          };

        formatter = nixpkgs.legacyPackages.${system}.nixfmt-tree;
      }
    );
}
