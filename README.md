# Terramate Github Action

This is a very simple Github Action that installs Terramate and allows you run any command and retrieve the stdout, stderr and exit code in subsequent commands. It is only compatible with Ubuntu runners.

## Usage

There are three optional inputs
* `tm_command` is the command to run, e.g. `run -- terraform apply`. Without this, the action only installs Terramate.
* `tm_version` is the version of Terramate to use, defaulting to the latest 
* `use_wrapper` if explicitly set to "false" Terramate will not be installed via a wrapper script (meaning you will have no access to the outputs)

Outputs are `stdout`, `stderr` and `exitcode` which can be used in subsequent commands, e.g.

```
      - id: plan
        uses: terramate-io/terramate-action@main
        with:
          tm_command: run -- terraform plan -no-color
      - name: Publish Plans for Changed Stacks
        uses: marocchino/sticky-pull-request-comment@v2
        with:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          message: |
            ${{ steps.plan.outputs.stdout }}
```

