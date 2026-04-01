{
  description = "A basic flake for my Lua projects";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    tatr = {
      url = "github:alexjercan/tatr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        # Optional: use external flake logic, e.g.
        # inputs.foo.flakeModules.default
      ];
      flake = {
        # Put your original flake attributes here.
      };
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        # self',
        pkgs,
        inputs',
        ...
      }: {
        packages.default = pkgs.vimUtils.buildVimPlugin {
          pname = "tatr-nvim";
          version = "0.1.0";
          src = ./.;

          buildInputs = [
            inputs'.tatr.packages.default
          ];

          meta = with pkgs.lib; {
            description = "Neovim plugin for tatr";
            homepage = "https://github.com/alexjercan/tatr.nvim";
            license = licenses.mit;
            platforms = platforms.all;
          };
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            lua
            luajitPackages.luacheck
            stylua
          ];

          buildInputs = [
            inputs'.tatr.packages.default
          ];
        };
      };
    };
}
