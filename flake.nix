{
  description = "A Typst project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    typix = {
      url = "github:loqusion/typix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    # Example of downloading icons from a non-flake source
    font-awesome = {
      url = "github:FortAwesome/Font-Awesome";
      flake = false;
    };

    typst-packages = {
      url = "github:typst/packages";
      flake = false;
    };

    ttt = {
      url = "github:matthiasbeyer/ttt";
      flake = false;
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      typix,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        typixLib = typix.lib.${system};

        src =
          let
            nixFilter = path: _type: !pkgs.lib.hasSuffix ".nix" path;
            extraFiles =
              path: _type:
              !(builtins.any (n: pkgs.lib.hasSuffix n path) [
                ".github"
                ".sh"
              ]);
            filterPath =
              path: type:
              builtins.all (f: f path type) [
                nixFilter
                extraFiles
                pkgs.lib.cleanSourceFilter
              ];
          in
          pkgs.lib.cleanSourceWith {
            src = ./.;
            filter = filterPath;
          };

        fontPaths = [
          # Add paths to fonts here
          "${pkgs.roboto}/share/fonts/truetype"
        ];

        virtualPaths = [
          # Add paths that must be locally accessible to typst here
          {
            dest = "icons";
            src = "${inputs.font-awesome}/svgs/regular";
          }
        ];

        commonArgs =
          { typstSource }:
          {
            inherit
              typstSource
              fontPaths
              virtualPaths
              ;
          };

        typstPackagesSrc = pkgs.symlinkJoin {
          name = "typst-packages-src";
          paths = [
            "${inputs.typst-packages}/packages"
          ];
        };

        typstPackagesCache = pkgs.stdenv.mkDerivation {
          name = "typst-packages-cache";
          src = typstPackagesSrc;
          dontBuild = true;
          installPhase = ''
            mkdir -p "$out/typst/packages"
            cp -LR --reflink=auto --no-preserve=mode -t "$out/typst/packages" "${typstPackagesSrc}"/*

            mkdir -p "$out/typst/packages/matthiasbeyer/ttt/0.1.0"
            cp -LR --reflink=auto --no-preserve=mode -t "$out/typst/packages/matthiasbeyer/ttt/0.1.0" "${inputs.ttt}"/*
          '';
        };

        # Compile a Typst project, *without* copying the result
        # to the current directory
        build-drv =
          { typstSource }:
          typixLib.buildTypstProject (
            (commonArgs { inherit typstSource; })
            // {
              inherit src;

              XDG_CACHE_HOME = typstPackagesCache;
            }
          );

        # Compile a Typst project, and then copy the result
        # to the current directory
        build-script =
          { typstSource }:
          typixLib.buildTypstProjectLocal (
            (commonArgs { inherit typstSource; })
            // {
              inherit src;

              XDG_CACHE_HOME = typstPackagesCache;
            }
          );

        # Watch a project and recompile on changes
        watch-script =
          { typstSource }:
          pkgs.writeShellApplication {
            name = "typst-watch";

            text =
              let
                watch = typixLib.watchTypstProject (commonArgs {
                  inherit typstSource;
                });
              in
              ''
                XDG_DATA_HOME="${typstPackagesCache}/" ${pkgs.lib.getExe watch}
              '';
          };

        paper-drv = build-drv { typstSource = "paper.typ"; };
        paper-build = build-script { typstSource = "paper.typ"; };
        paper-watch = watch-script { typstSource = "paper.typ"; };

        transcript-drv = build-drv { typstSource = "transcript.typ"; };
        transcript-build = build-script { typstSource = "transcript.typ"; };
        transcript-watch = watch-script { typstSource = "transcript.typ"; };
      in
      {
        checks = {
          inherit
            paper-build
            paper-watch

            transcript-build
            transcript-watch
            ;
        };

        packages = {
          inherit
            paper-drv
            transcript-drv
            ;

          inherit
            typstPackagesSrc
            typstPackagesCache
            ;
        };

        apps = {
          paper-build = flake-utils.lib.mkApp { drv = paper-build; };
          paper-watch = flake-utils.lib.mkApp { drv = paper-watch; };
          transcript-build = flake-utils.lib.mkApp { drv = transcript-build; };
          transcript-watch = flake-utils.lib.mkApp { drv = transcript-watch; };
        };

        devShells.default = typixLib.devShell {
          inherit fontPaths virtualPaths;

          shellHook = ''
            # We set the XDG_CACHE_HOME to the typstPackageCache, so we can
            # compile in the nix-develop shell
            echo >&2 "Setting XDG_CACHE_HOME"
            export XDG_CACHE_HOME="${typstPackagesCache}"
          '';

          packages = [
            # WARNING: Don't run `typst-build` directly, instead use `nix run .#build`
            # See https://github.com/loqusion/typix/issues/2
            # build-script
            # More packages can be added here, like typstfmt
            pkgs.typstfmt
          ];
        };
      }
    );
}
