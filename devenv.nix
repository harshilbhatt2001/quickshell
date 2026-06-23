{
  pkgs,
  ...
}:

{
  env.DEVSHELL_NAME = "󰏖 devenv/#fab387| quickshell/green";

  packages = with pkgs; [
    quickshell
    kdePackages.qtdeclarative
  ];

  processes = {
    qs.exec = "quickshell -p .";
  };
}
