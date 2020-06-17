import ./make-test.nix (
  { pkgs, ... }: {
    name = "profiles-desktop";
    meta = with pkgs.stdenv.lib.maintainers; {
      maintainers = [ kampka ];
    };

    nodes.default = {
      kampka.profiles.desktop.enable = true;
    };

    testScript = ''
      start_all()
      default.wait_for_unit("multi-user.target")
    '';
  }
)
