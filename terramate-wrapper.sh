#!/bin/bash
terramate-bin "$@" > >(tee /tmp/stdout) 2> >(tee /tmp/stderr)
exitcode=$?
echo "exitcode=$exitcode" >> "$GITHUB_OUTPUT"
echo 'stdout<<EOF' >> "$GITHUB_OUTPUT"
cat /tmp/stdout >> "$GITHUB_OUTPUT"
echo EOF >> "$GITHUB_OUTPUT"
echo 'stderr<<EOF' >> "$GITHUB_OUTPUT"
cat /tmp/stderr >> "$GITHUB_OUTPUT"
echo EOF >> "$GITHUB_OUTPUT"
exit $exitcode

