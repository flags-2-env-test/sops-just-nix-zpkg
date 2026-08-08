# sops-just-nix-zpkg

Runtime-generated security fixture for **SOPS + Just + Nix + Zed package** interoperability.

This lane uses the same hardened SOPS dotenv contract as the other `flags-2-env-test` matrix repositories. Private age identities, temporary SOPS config, canonical runtime ciphertext, decrypted `env/dec/**`, and root `.env` are created only while tests run and are removed afterward. **No private identity or decrypted dotenv is committed.**

CI exercises the contract through pinned Nix/Just and a clean container. It then builds a pinned Zed CLI and deliberately creates synthetic plaintext/runtime identity files before `zed pack`; the resulting archive must exclude root `.env`, `env/dec/**`, `.fixture-runtime/**`, temporary SOPS config, and `_tooling/**` while retaining the neutral fixture sources and package metadata.

All values are synthetic. No application credential or production SOPS identity is used.

## Local verification

```sh
nix run --no-write-lock-file .#verify
nix develop --no-write-lock-file --command just verify
docker build -t sops-just-nix-zpkg-runtime .
docker run --rm sops-just-nix-zpkg-runtime
```

The Zed packaging assertion is run in CI with immutable `zed-cli` and `zed-interfaces` revisions.
