{
  description = "A simple Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {

          name = "flake";

          buildInputs = with pkgs; [
            quickshell
          ];

          # Environment variables
          shellHook = ''
            					  export DEVSHELL_NAME="󱄅 flake/#89dceb| quickshell/green"

                        # Trigger zsh
                        if [[ -z "$ZSH_VERSION" ]]; then
                          exec zsh
                        fi
          '';
        };
      }
    );
}
