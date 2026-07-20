{
  lib,
  stdenv,
  fetchurl,
}:

let
  version = "2.1.1";

  # Upstream publishes a prebuilt `linear` binary per target; map each Nix
  # system to the matching release asset and pin its tarball hash.
  distTargets = {
    x86_64-linux = {
      triple = "x86_64-unknown-linux-gnu";
      hash = "sha256-aMrqS0lPY57/pmEmYrtii6fz+M123bznsqnJYrsBSmQ=";
    };
    aarch64-linux = {
      triple = "aarch64-unknown-linux-gnu";
      hash = "sha256-uKdeImYkYOhwriV1ordRCg0MRSntZC2tPQvRdTI8flI=";
    };
    x86_64-darwin = {
      triple = "x86_64-apple-darwin";
      hash = "sha256-GeQR4wWpCz5rvd/8iwyTq54mr30Hdhvkg9aPRQ4N/MM=";
    };
    aarch64-darwin = {
      triple = "aarch64-apple-darwin";
      hash = "sha256-HfXZVYWn01wEb6MzAfJ6zZSDws3ctmiC0S8aEf58HC0=";
    };
  };

  target =
    distTargets.${stdenv.hostPlatform.system}
      or (throw "linear-cli: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "linear-cli";
  inherit version;

  src = fetchurl {
    url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-${target.triple}.tar.xz";
    inherit (target) hash;
  };

  # The tarball unpacks into linear-<triple>/; descend straight into it.
  sourceRoot = "linear-${target.triple}";

  # The binary is produced by `deno compile`, which embeds the JS bundle in a
  # binary section that both patchelf and strip drop, leaving a binary that
  # fails at startup with "Could not find standalone binary section." So
  # install it untouched: no autoPatchelfHook, no strip. It stays dynamically
  # linked against the host's glibc, which is fine since this is only used on
  # non-NixOS machines.
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 linear $out/bin/linear
    install -Dm644 LICENSE $out/share/licenses/linear-cli/LICENSE

    runHook postInstall
  '';

  meta = {
    description = "CLI for linear.app: list, start, and create PRs for issues; git/jj aware and agent friendly";
    homepage = "https://github.com/schpet/linear-cli";
    changelog = "https://github.com/schpet/linear-cli/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "linear";
    platforms = lib.attrNames distTargets;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
