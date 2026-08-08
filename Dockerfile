FROM nixos/nix:2.35.1-amd64

ARG NIXPKGS_REF=b7c2ada94fe99c15b0dbcf4d11fd7850b957a436

WORKDIR /fixture
COPY . .

# Recreate a minimal Git repository without importing caller Git metadata. Git
# itself comes transiently from the same exact nixpkgs pin used by flake.nix.
RUN nix \
      --extra-experimental-features nix-command \
      --extra-experimental-features flakes \
      --option sandbox false \
      shell "github:NixOS/nixpkgs/${NIXPKGS_REF}#git" \
      --command sh -c 'git init -q \
        && git config user.name fixture \
        && git config user.email fixture@example.invalid \
        && git add -A \
        && git commit -qm fixture'

CMD ["nix", "--extra-experimental-features", "nix-command", "--extra-experimental-features", "flakes", "--option", "sandbox", "false", "develop", "--no-write-lock-file", "--command", "just", "verify"]
