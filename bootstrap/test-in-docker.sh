#!/usr/bin/env bash
# test-in-docker.sh — installe les dotfiles dans un conteneur Ubuntu 26.04 vierge
# (utilisateur non root) et vérifie que le shell se charge correctement.
set -euo pipefail

REPO="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
IMAGE="${IMAGE:-ubuntu:26.04}"

docker run --rm -t -v "$REPO:/src:ro" "$IMAGE" bash -euo pipefail -c '
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq --no-install-recommends git sudo curl ca-certificates >/dev/null
  useradd -m -s /bin/bash test
  echo "test ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/test
  cp -r /src /home/test/dotfiles && chown -R test:test /home/test
  su - test -c "
    export DEBIAN_FRONTEND=noninteractive
    set -e
    ~/dotfiles/install.sh
    ~/dotfiles/bootstrap/install-packages.sh --only apt,node
    bash -lic \"type ll; starship --version; eza --version; tldr --version; vp --version; node -v; command -v node pnpm; echo PATH=\\\$PATH\"
    bash -lc \"node -v\"
    cmp ~/dotfiles/bash/bashrc /src/bash/bashrc && cmp ~/dotfiles/bash/profile /src/bash/profile
    test -L ~/.bashrc && test -L ~/.profile && echo \"shell intact\"
  "
'
