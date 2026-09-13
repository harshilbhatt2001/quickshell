{
  pkgs,
  ...
}:

{
  env.DEVSHELL_NAME = "󰏖 devenv/#fab387| quickshell/green";

  packages = with pkgs; [
    quickshell
    kdePackages.qtdeclarative
    gcalcli
  ];

  processes = {
    qs.exec = "quickshell -p .";
  };

  # Point qmlls/qmllint at the QML modules in the Nix store, regenerated on
  # shell entry so the paths track the pinned package versions.
  enterShell = ''
    cat > "$DEVENV_ROOT/.qmlls.ini" <<EOF
    [General]
    no-cmake-calls=true
    importPaths=${pkgs.quickshell}/lib/qt-6/qml:${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml
    EOF
  '';
}
