{ writeShellApplication, jq }:

writeShellApplication {
  name = "cl";
  runtimeInputs = [ jq ];
  text = builtins.readFile ./cl.sh;
}
