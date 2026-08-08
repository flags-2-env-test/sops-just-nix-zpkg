# Expected behavior

This variant must preserve the exact no-private-key SOPS contract from the clean Just and Nix references while proving Just is only an invocation layer.

A passing run proves:

1. The committed tree contains no private age identity and no tracked plaintext dotenv-like path.
2. A fresh age identity is generated at runtime with mode `0600` and is never logged.
3. Exact runtime rules select only `env/enc/dev.env.enc` and `env/enc/prod.env.enc`.
4. SOPS uses explicit dotenv input/output types and filename override for `.env.enc` creation.
5. Synthetic plaintext never appears in ciphertext; decrypt without the generated identity fails.
6. Dev/prod round-trip exactly and decrypted files remain `0600` under ignored `env/dec/`.
7. An unmanaged root `.env` is refused; the managed root `.env` is a relative symlink.
8. Normal Git staging rejects plaintext state while allowing exactly the two canonical ciphertext paths.
9. Runtime identity/config/ciphertext/plaintext/symlink state is cleaned up.
10. `nix run .#verify` passes the shared contract directly.
11. `nix develop --command just verify` passes the same contract through Just supplied by the pinned dev shell.
12. The clean official-Nix container runs `just verify` from inside `nix develop` and passes the same contract.
13. The checkout remains clean after host runtime cleanup.
14. This repo does not participate in the `flags-2-env` upstream dispatch fleet unless it later declares that dependency explicitly.
