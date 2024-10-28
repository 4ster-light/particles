{
  description = "Love2D Particle Simulator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "particle-simulator";
          src = ./.;
          
          buildInputs = with pkgs; [
            love
            lua
          ];

          installPhase = ''
            mkdir -p $out/bin
            mkdir -p $out/share/particle-simulator
            
            # Copy the Lua source file
            cp *.lua $out/share/particle-simulator/
            
            # Create a wrapper script
            cat > $out/bin/particle-simulator <<EOF
            #!${pkgs.bash}/bin/bash
            exec ${pkgs.love}/bin/love $out/share/particle-simulator
            EOF
            
            chmod +x $out/bin/particle-simulator
          '';
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/particle-simulator";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            love
            lua
          ];
        };
      });
}
