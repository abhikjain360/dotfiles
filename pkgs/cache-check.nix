{ writeShellApplication, jq }:

writeShellApplication {
  name = "cache-check";
  runtimeInputs = [ jq ];
  text = builtins.readFile ./cache-check.sh;
}
