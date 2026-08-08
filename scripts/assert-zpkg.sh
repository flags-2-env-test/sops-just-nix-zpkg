#!/usr/bin/env bash
set -euo pipefail
[[ $# -eq 1 ]] || { echo 'usage: assert-zpkg.sh /path/to/zed' >&2; exit 2; }
zed="$1"
[[ -x "$zed" ]] || { echo "zed binary not executable: $zed" >&2; exit 2; }
cleanup() { rm -rf -- .fixture-runtime env/dec env/enc .env .fixture.sops.yaml .zed; }
trap cleanup EXIT HUP INT TERM
cleanup
mkdir -p .fixture-runtime env/dec
private_marker='AGE-SECRET''-KEY-SYNTHETIC-DO-NOT-USE'
printf '%s\n' "$private_marker" > .fixture-runtime/age.key
chmod 600 .fixture-runtime/age.key
plaintext_marker='SYNTHETIC_DEV=not-a-secret'
printf '%s\n' "$plaintext_marker" > env/dec/dev.env
chmod 600 env/dec/dev.env
ln -s env/dec/dev.env .env
printf 'creation_rules: []\n' > .fixture.sops.yaml
out="$(mktemp -d "${TMPDIR:-/tmp}/sops-zpkg-pack.XXXXXX")"
"$zed" pack --out "$out" >/dev/null
archive="$(find "$out" -maxdepth 1 -name '*.tar.gz' -print -quit)"
[[ -n "$archive" ]]
tar -tzf "$archive" > "$out/files.txt"
grep -Fxq 'pkg/.zpkg.toml' "$out/files.txt"
grep -Fxq 'pkg/fixtures/dev.fixture.dotenv' "$out/files.txt"
grep -Fxq 'pkg/fixtures/prod.fixture.dotenv' "$out/files.txt"
grep -Fxq 'pkg/scripts/assert.sh' "$out/files.txt"
! grep -Eq '^pkg/(\.env($|\.)|env/dec/|\.fixture-runtime/|\.fixture\.sops\.yaml$|_tooling/)' "$out/files.txt"
! tar -xOzf "$archive" 2>/dev/null | grep -Fq "$private_marker"
! tar -xOzf "$archive" 2>/dev/null | grep -Fq "$plaintext_marker"
echo 'runtime-generated SOPS Zed package exclusion contract: PASS'
