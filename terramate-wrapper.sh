#!/bin/bash

tmpdir=$(mktemp -d)

stdout="${tmpdir}/stdout.txt"
stderr="${tmpdir}/stderr.txt"

terramate-bin "$@" > >(tee "${stdout}") 2> >(tee "${stderr}")

exitcode=$?

echo "exitcode=${exitcode}" >> "$GITHUB_OUTPUT"

echo 'stdout<<EOF' >> "$GITHUB_OUTPUT"
cat "${stdout}" >> "$GITHUB_OUTPUT"
echo EOF >> "$GITHUB_OUTPUT"

echo 'stderr<<EOF' >> "$GITHUB_OUTPUT"
cat "${stderr}" >> "$GITHUB_OUTPUT"
echo EOF >> "$GITHUB_OUTPUT"

exit ${exitcode}
