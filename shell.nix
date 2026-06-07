{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    name = "kde-plasma-applet-menupager";

    nativeBuildInputs = with pkgs.buildPackages; [
      kdePackages.plasma-sdk    #plasmoidviewer
      kdePackages.qtdeclarative #qmllint
    ];

}
