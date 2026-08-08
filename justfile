set shell := ["bash", "-euo", "pipefail", "-c"]

verify:
    @bash scripts/assert.sh

verify-nix:
    @nix run --no-write-lock-file .#verify

verify-docker:
    @docker build --tag sops-just-nix-runtime-fixture . >/dev/null
    @docker run --rm sops-just-nix-runtime-fixture
