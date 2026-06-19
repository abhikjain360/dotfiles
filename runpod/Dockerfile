# syntax=docker/dockerfile:1

# RunPod GPU dev box: Ubuntu + Nix + your home-manager env, with NVIDIA's
# cuda-oxide toolchain (CUDA 13 / LLVM 22 / nightly Rust) pre-downloaded into
# the Nix store so `nix develop` is instant on a fresh pod.
#
# Your project CODE does not live here -- it lives in GitHub and is cloned per
# pod. This image only carries the heavy, reusable dependency closures.
#
# ---------------------------------------------------------------------------
# Build + push. Must run on an x86_64 Linux host: your Mac is aarch64 and
# RunPod needs linux/amd64. Easiest host is a cheap RunPod CPU pod (or any x86
# Linux box / CI runner); build there once, then GPU pods just pull it.
#
#   docker build -t ghcr.io/abhikjain360/runpod-cuda:v0.2.1 \
#                -t ghcr.io/abhikjain360/runpod-cuda:latest .
#   echo "$GHCR_PAT" | docker login ghcr.io -u abhikjain360 --password-stdin
#   docker push ghcr.io/abhikjain360/runpod-cuda:v0.2.1
#   docker push ghcr.io/abhikjain360/runpod-cuda:latest
#
# $GHCR_PAT = a GitHub personal access token with the `write:packages` scope.
# Afterwards mark the package Public at github.com/users/abhikjain360/packages so
# RunPod can pull it with no credentials.
# ---------------------------------------------------------------------------

FROM ubuntu:24.04

ENV HOME=/root \
    USER=root \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# zsh here is just the bootstrap login shell; home-manager's generated ~/.zshrc
# takes over PATH/prompt/plugins once it loads.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git xz-utils sudo locales zsh \
 && locale-gen en_US.UTF-8 \
 && rm -rf /var/lib/apt/lists/*

# Determinate Systems Nix installer -- handles root + containers cleanly
# (creates the nixbld build users, enables flakes by default). `--init none`
# because there is no systemd in the image; as root, nix uses the local store
# directly without a running daemon. `sandbox = false` since the container
# can't always set up the build sandbox. The trailing `nix --version` asserts
# the install actually succeeded (the installer's self-test warning under
# `--init none` is expected and non-fatal).
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
      | sh -s -- install linux --init none --no-confirm --extra-conf "sandbox = false" \
 && /nix/var/nix/profiles/default/bin/nix --version

# Put nix on PATH for the remaining build steps and at runtime.
ENV PATH=/nix/var/nix/profiles/default/bin:/root/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Your home-manager config, at the same path it lives on your Mac so the
# out-of-store symlinks (nvim/zellij/beets/codex) resolve identically.
COPY . /root/.config/home-manager

# Build + activate the runpod generation using the flake-locked home-manager
# (reproducible), then drop the build symlink.
RUN cd /root/.config/home-manager \
 && nix build --no-warn-dirty \
      '.#homeConfigurations."abhik@runpod".activationPackage' \
      --out-link /tmp/hm \
 && /tmp/hm/activate \
 && rm /tmp/hm

# Pre-warm cuda-oxide's dev environment: realise CUDA 13 + LLVM 22 + nightly
# Rust into /nix/store WITHOUT running the driver-discovery shellHook (there is
# no GPU at build time). `print-dev-env` is exactly what direnv / `nix develop`
# evaluate, so this is the cache they hit later. Pin a ref so your per-project
# `nix develop` resolves to the same store paths and stays a cache hit.
ARG CUDA_OXIDE_REF=v0.2.1
RUN nix print-dev-env --accept-flake-config --no-warn-dirty \
      "github:NVlabs/cuda-oxide/${CUDA_OXIDE_REF}" >/dev/null

# If RunPod execs `bash`, load the home-manager env and hand off to zsh.
RUN printf '%s\n' \
  '# home-manager env + drop into zsh' \
  'for f in "$HOME"/.nix-profile/etc/profile.d/hm-session-vars.sh "$HOME"/.local/state/nix/profiles/home-manager/etc/profile.d/hm-session-vars.sh; do' \
  '  [ -e "$f" ] && . "$f"' \
  'done' \
  '[ -z "$ZSH_VERSION" ] && command -v zsh >/dev/null && exec zsh -l' \
  >> /root/.bashrc

WORKDIR /root

# --- RunPod SSH access -------------------------------------------------------
# RunPod's ssh.runpod.io proxy connects to an sshd INSIDE the container and
# injects your account's public keys as $PUBLIC_KEY at runtime. A bare image has
# no sshd, so `runpodctl ssh info` reports "pod not ready" and connecting fails.
# Install sshd, set root's login shell to zsh (so SSH sessions load your
# home-manager env), and ensure nix is on PATH for those sessions.
RUN apt-get update \
 && apt-get install -y --no-install-recommends openssh-server \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /run/sshd /etc/zsh \
 && sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config \
 && usermod -s /usr/bin/zsh root \
 && printf '%s\n' '. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh 2>/dev/null || true' >> /etc/zsh/zshenv

# Entrypoint: install RunPod's injected key into authorized_keys, then run sshd
# in the foreground as the container's main process (keeps the pod alive).
RUN printf '%s\n' \
  '#!/usr/bin/env bash' \
  'set -e' \
  'mkdir -p /root/.ssh /run/sshd' \
  'chmod 700 /root/.ssh' \
  'if [ -n "${PUBLIC_KEY:-}" ]; then echo "$PUBLIC_KEY" >> /root/.ssh/authorized_keys; chmod 600 /root/.ssh/authorized_keys; fi' \
  'ssh-keygen -A >/dev/null 2>&1 || true' \
  'exec /usr/sbin/sshd -D -e' \
  > /usr/local/bin/runpod-entrypoint.sh \
 && chmod +x /usr/local/bin/runpod-entrypoint.sh

# Document the SSH port. RunPod still requires `--ports "22/tcp"` at pod
# creation for its proxy / `runpodctl ssh info` to consider the pod reachable.
EXPOSE 22

ENTRYPOINT ["/usr/local/bin/runpod-entrypoint.sh"]
