# Terramate Github Action

This is a very simple Github Action that installs Terramate and (by default) a wrapper that allows you to use the stdout, stderr and exit code in subsequent workflow steps. It is only compatible with Ubuntu runners.

## Usage

There are three optional inputs
* `version` is the version of Terramate to use. If not defined, the [asdf](https://asdf-vm.com/) `.tool-versions` file is checked, and if that doesn't contain a Terramate entry then the latest Terramate version is used by default.
* `use_wrapper` if explicitly set to `false` Terramate CLI will not be called via a wrapper script. This means that the GitHub Action Outputs cannot be used in subsequent steps.
* `cloud_organization` sets the Terramate Cloud organization to use for all steps in this job

Outputs are `stdout`, `stderr` and `exitcode` which can be used in subsequent commands, e.g.

```yaml
- name: Install terramate
  uses: terramate-io/terramate-action@main

- name: Terramate run plan
  id: plan
  run: terramate run --changed --disable-check-gen-code -- terraform plan -lock-timeout=5m -out out.tfplan

- name: Publish Plans for Changed Stacks
  uses: marocchino/sticky-pull-request-comment@v2
  with:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    message: |
      ${{ steps.plan.outputs.stdout }}
```

There is a full example [here](./examples/basic.yml)

