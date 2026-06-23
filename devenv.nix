{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    quickshell
    kdePackages.qtdeclarative
  ];
  env.DEVSHELL_NAME = "󰏖 devenv/#fab387| quickshell/green";
}
