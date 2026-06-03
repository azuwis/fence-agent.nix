let
  sources = import ./nix/sources.nix { };
  pkgs = import sources.nixpkgs {
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (pkgs.lib.getName pkg) [
        "claude-code"
      ];
  };
  fence-agent = pkgs.callPackage ./nix/fence-agent.nix { };
  fence-claude = pkgs.callPackage ./nix/fence-claude.nix { inherit fence-agent; };
  fence-pi = pkgs.callPackage ./nix/fence-pi.nix { inherit fence-agent; };
in

fence-claude
// {
  inherit fence-claude;
  inherit fence-pi;
}
