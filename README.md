# Terramate Github Action

[![Terramate Action Tests](https://github.com/terramate-io/terramate-action/actions/workflows/tests.yml/badge.svg)](https://github.com/terramate-io/terramate-action/actions/workflows/tests.yml)

The [`terramate-io/terramate-action`] is a GitHub composite action that sets up Terramate CLI in your GitHub Actions workflows.

- It downloads a specific version or a [asdf] configured version of [Terramate CLI].
- It installs [Terramate CLI] into a user specified path or by default to `/usr/local/bin`
- It installs a wrapper script by default so that calls to `terramate` binary will expose GitHub Action outputs to access the `stderr`, `stderr`, and the `exitcode` of the `terramate` execution.
- It allows you to configure a default [Terramate Cloud] organization to use Terramate Cloud Features like Drift Detection and Stack Health Information.

## Compatbility

The action currently only supports `ubuntu` runners.

## Usage

The version argument should be used to specify the desired terramate version to install.

```yaml
steps:
  - uses: terramate-io/terramate-action@v3
    with:
      version: "0.14.0"
```

The default version is `"detect"`.
The terramate version to use needs to be defined in a `.tool-versions` file as defined by [asdf].
This is the recommended way to specify the version so updates can be made in a single location.

```yaml
# file: .tool-versions
terramate 0.14.0
```

```yaml
steps:
  - uses: terramate-io/terramate-action@v3
    with:
      version: "detect"
```

or just

```yaml
steps:
  - uses: terramate-io/terramate-action@v3
```

The binary will be installed to `/usr/local/bin` by default. This location can be changed using the `bindir` argument:

```yaml
steps:
  - uses: terramate-io/terramate-action@v3
    with:
      bindir: /usr/local/bin
```

To configure the default [Terramate Cloud] Organization set `cloud_organization` argument to your organization short name:

```yaml
steps:
  - uses: terramate-io/terramate-action@v3
    with:
      cloud_organization: myorganization
```

To disable using the optional wrapper script by default the `use_wrapper` argument can be set to `"false"`:

```yaml
steps:
  - uses: terramate-io/terramate-action@v3
    with:
      use_wrapper: "false"
```

Subsequent steps can access outputs when the wrapper script is installed:

```yaml
steps:
  - uses: terramate-io/terramate-action@v3

  - id: list
    run: terramate list --changed

  - run: echo ${{ steps.list.outputs.stdout }}
  - run: echo ${{ steps.list.outputs.stderr }}
  - run: echo ${{ steps.list.outputs.exitcode }}
```

## License

See the [LICENSE](./LICENSE) file for licensing information.

## Terramate

Terramate is a [CNCF](https://landscape.cncf.io/card-mode?organization=terramate&grouping=organization)
and [Linux Foundation](https://www.linuxfoundation.org/membership/members/) silver member.

<img src="https://raw.githubusercontent.com/cncf/artwork/master/other/cncf-member/silver/color/cncf-member-silver-color.svg" width="300px" alt="CNCF Silver Member logo" />

<!-- links -->

[asdf]: https://asdf-vm.com/
[`terramate-io/terramate-action`]: https://github.com/terramate-io/terramate-action
[Terramate CLI]: https://terramate.io/cli/docs
[Terramate Cloud]: https://terramate.io
