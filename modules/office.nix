{ pkgs, lib, config, ... }:
# Office Applications Module
# Provides document editing, spreadsheets, presentations
# Currently: OnlyOffice Desktop Editors

let
  cfg = config.modules.office;
in
{
  options.modules.office = {
    enable = lib.mkEnableOption "Office applications (OnlyOffice)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.onlyoffice-desktopeditors
    ];
  };
}
