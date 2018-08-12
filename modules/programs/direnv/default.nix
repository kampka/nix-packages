{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.direnv;

in {

  options.programs.direnv = {
    enable = mkEnableOption "direnv - environment switcher for the shell";

    configureZsh = mkOption {
      type = types.bool;
      default = true;
      description = "Whether or not to enable zsh configuration.";
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.direnv ];

    programs.zsh.interactiveShellInit = mkIf cfg.configureZsh ''
      if [ -z "$DIRENV_LOADED" ]; then
        eval "$(direnv hook zsh)"
        export DIRENV_LOADED="true"
      fi
    '';
  };
}
