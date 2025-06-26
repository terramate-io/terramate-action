# Terramate Github Action

[![Terramate Action Tests](https://github.com/terramate-io/terramate-action/actions/workflows/tests.yml/badge.svg)](https://github.com/terramate-io/terramate-action/actions/workflows/tests.yml)

The [`terramate-io/terramate-action`] is a GitHub composite action that sets up Terramate CLI in your GitHub Actions workflows.

- It downloads a specific version or falls back to an [asdf] configured version or the latest available release of [Terramate CLI].
- It installs [Terramate CLI] into a user specified path or by default to `/usr/local/bin`
- It installs a wrapper script by default so that calls to `terramate` binary will expose GitHub Action outputs to access the `stderr`, `stderr`, and the `exitcode` of the `terramate` execution.
- It allows you to configure a default [Terramate Cloud] organization to use Terramate Cloud Features like Drift Detection and Stack Health Information.

## Compatbility

The action currently only supports `ubuntu` runners.
Please open an issue, if more runner support is required.

## Usage

The default action installs Terramate CLI in it's latest version unless a specific version is configured by [asdf] config file `.tool-versions`.

> [!IMPORTANT]
> DEPRECATION NOTICE: We will discontinue to support running the terramate action without specifying any version when there is no [asdf] configuration found.
> This is to safeguard you against accidental upgrades of incompatible terramate version.

```yaml
steps:
  - uses: terramate-io/terramate-action@v2
```

You can disable [asdf] integration fallback by explicitly specifying `"latest"` as the desired version.

> [!CAUTION]
> Using `"latest"` should be avoided for any live workflows. This is purely useful in test or demo environments.

```yaml
steps:
  - uses: terramate-io/terramate-action@v2
    with:
      version: "latest"
```

To install a specific version the version can be specified using the `version` argument:

```yaml
steps:
  - uses: terramate-io/terramate-action@v2
    with:
      version: "0.13.3"
```

The binary will be installed to `/usr/local/bin` by default. This location can be changed using the `bindir` argument:

```yaml
steps:
  - uses: terramate-io/terramate-action@v2
    with:
      bindir: /usr/local/bin
```

To configure the default [Terramate Cloud] Organization set `cloud_organization` argument to your organization short name:

```yaml
steps:
  - uses: terramate-io/terramate-action@v2
    with:
      cloud_organization: myorganization
```

To disable using the optional wrapper script by default the `use_wrapper` argument can be set to `"false"`:

```yaml
steps:
  - uses: terramate-io/terramate-action@v2
    with:
      use_wrapper: "false"
```

Subsequent steps can access outputs when the wrapper script is installed:

```yaml
steps:
  - uses: terramate-io/terramate-action@v2
    with:
      version: "0.13.3"

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
