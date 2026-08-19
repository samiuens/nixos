{ ... }:

{
  imports = [
    ../../modules/darwin
  ];

  system = {
    primaryUser = "smi";
    stateVersion = 6;
  };
}
