{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.tmux;

  tmuxConfig = pkgs.writeText "tmux.conf" ''
  ${optionalString (cfg.configurePowerline) ''
  # Source the powerline shell configuration
  source "${cfg.powerlinePackage}/share/tmux/powerline.conf"
  '' }

  # Keep tmux alive even if there is no active session left
  set -g exit-empty off

  # Source users tmux.conf
  if-shell "test -e $HOME/.tmux.conf" 'source "$HOME/.tmux.conf"'
  '';


in {

  options.services.tmux = {
    enable = mkEnableOption "tmux user service";

    configurePowerline = mkOption {
      type = types.bool;
      default = true;
      description = "Whether or not to enable powerline for tmux.";
    };

    powerlinePackage = mkOption {
      type = types.package;
      default = pkgs.python27Packages.powerline;
      description = "The powerline package to install";
    };

    sessionName = mkOption {
      type = types.string;
      default = "default";
      description = "The name of the tmux session to spawn.";
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.tmux ];

    systemd.user.services.tmux = {
      description = "tmux terminal multiplexer";

      serviceConfig = {
        Type      = "forking";
        ExecStart = "${pkgs.tmux}/bin/tmux -f ${tmuxConfig} start-server";
        ExecStop  = "${pkgs.tmux}/bin/tmux kill-server";
        Restart   = "always";
        RemainAfterExit = true;
      };
      wantedBy = [ "default.target" ];

      path = [ pkgs.tmux cfg.powerlinePackage ];
    };
  };
}
