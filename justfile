# just is the task runner half of this fixture.
set shell := ["bash", "-euo", "pipefail", "-c"]

_fmt := "--input-type dotenv --output-type dotenv"

# Run the shared contract (same script CI runs).
verify:
    @SOPS_AGE_KEY_FILE=age.key scripts/assert.sh

# Decrypt to env/dec (gitignored, 0600).
decrypt:
    @mkdir -p env/dec && chmod 700 env/dec
    @SOPS_AGE_KEY_FILE=age.key sops decrypt {{ _fmt }} env/enc/dev.env.enc > env/dec/dev.env
    @chmod 600 env/dec/dev.env && echo "wrote env/dec/dev.env"

# Prove the same contract holds inside a container.
verify-docker:
    @docker build -q -t $(basename $PWD)-fixture . >/dev/null && docker run --rm $(basename $PWD)-fixture
