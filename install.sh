#!/bin/bash

set -eu

## GHA inputs

input_use_wrapper=${TMA_INPUT_USE_WRAPPER-true}
input_tm_version=${TMA_INPUT_VERSION-detect}
input_bindir=${TMA_INPUT_BINDIR-/usr/local/bin}
input_use_catalyst=${TMA_INPUT_USE_CATALYST-false}

## GHA context

context_github_action_path=${GITHUB_ACTION_PATH-}

## CE and CATALYST Setup

if [ "${input_use_catalyst}" == "true" ] ; then
  echo >&2 "Using Terramate Catalyst"
  cli_repository="terramate-io/terramate-catalyst"
  cli_asdf_slug="terramate-catalyst"
else
  echo >&2 "Using Terramate Community Edition"
  cli_repository="terramate-io/terramate"
  cli_asdf_slug="terramate"
fi

## functions

get_latest_version() {
  echo >&2 "get_latest_version: Getting latest Terramate release information from GitHub Releases"

  latest_url="https://api.github.com/repos/${cli_repository}/releases/latest"
  latest_json=$(curl -s "${latest_url}")
  tag_version=$(jq -r .tag_name <<<"${latest_json}")

  if [ -z "${tag_version}" ] || [ "${tag_version}" == "null" ] ; then
    echo >&2 "get_latest_version: ERROR: Can not extract version from latest ${cli_repository} release on GitHub:"
    cat >&2 "${latest_json}"
    exit 1
  fi

  echo >&2 "get_latest_version: Using latest version ${tag_version#v} of ${cli_repository}!"

  echo "${tag_version#v}"
}

get_asdf_version() {
  asdf_config_file=".tool-versions"

  if [ ! -r "${asdf_config_file}" ] ; then
    echo >&2 "get_asdf_version: ERROR. No config file found at ${asdf_config_file}!"
    exit 1
  fi

  echo >&2 "get_asdf_version: Getting desired '${cli_asdf_slug}' version from asdf config at ${asdf_config_file}!"

  asdf_version=$(awk "\$1 == \"${cli_asdf_slug}\" {print \$2}" "${asdf_config_file}")

  if [ -z "${asdf_version}" ] ; then
    echo >&2 "get_asdf_version: ERROR. No '${cli_asdf_slug}' config found in asdf file ${asdf_config_file}!"
    exit 1
  else
    echo >&2 "get_asdf_version: Using asdf provided version ${asdf_version} for ${cli_asdf_slug}!"
    echo "${asdf_version}"
  fi
}

get_version() {
  if [ "${input_tm_version}" == "detect" ] ; then
    echo >&2 "get_version: Detecting version using asdf provided config for ${cli_asdf_slug}!"
    get_asdf_version
    return
  fi

  ## DO NOT USE latest! Unsolicited aka automatic updates are risky and could introduce undetected bugs.
  if [ "${input_tm_version}" == "latest" ] ; then
    echo >&2 "get_version: WARNING: Using 'latest' should be avoided. Please pin a specific Terramate version to use."
    get_latest_version
    return
  fi

  echo >&2 "get_version: Using user provided version ${input_tm_version} for ${cli_asdf_slug}!"
  echo "${input_tm_version}"
  return
}

## main install function

install() {
  destdir="${input_bindir}"

  version=$(get_version)
  echo >&2 "install: Preparing download of ${cli_asdf_slug} v${version}"

  tmpdir=$(mktemp -d)
  echo >&2 "install: Created tmp directory at ${tmpdir}"

  system=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch=$(uname -m)

  if ! [[ "${system}" =~ ^(linux|darwin)$ ]]; then
    echo >&2 "install: Unsupported system ${system}."
    exit 1
  fi

  case "${arch}" in
    x86_64|x64) arch=x86_64 ;;
    aarch64|arm64) arch=arm64 ;;
    i386|i686) arch=i386 ;;
    *) echo >&2 "install: Unsupported architecture ${arch}." && exit 1 ;;
  esac

  if [ "${system}" == "darwin" ] && [ "${arch}" == "i386" ] ; then
    echo >&2 "install: Unsupported architecture: darwin/i386"
    exit 1
  fi

  echo >&2 "install: Selected release to download: ${cli_asdf_slug} v${version} for ${system}/${arch}"

  url="https://github.com/${cli_repository}/releases/download/v${version}/${cli_asdf_slug}_${version}_${system}_${arch}.tar.gz"

  echo >&2 "install: Downloading from ${url}"

  status=$(curl -w "%{http_code}" -o "${tmpdir}/terramate.tar.gz" -L "${url}")
  if [ "${status}" != "200" ] ; then
    echo >&2 "install: ERROR: Failed to download release. Expected HTTP status 200 and got ${status}."
    exit 1
  fi

  echo >&2 "install: extracting terramate binary into ${tmpdir}"
  tar xzf "${tmpdir}/terramate.tar.gz" -C "${tmpdir}" terramate

  echo >&2 "install: installing terramate into ${destdir}"
  cp "${tmpdir}/terramate" "${destdir}/terramate-bin"

  if [ "${input_use_wrapper}" != "false" ] && [ -n "${context_github_action_path}" ] ; then
    echo >&2 "install: installing terramate-wrapper into ${destdir}"
    cp "${context_github_action_path}/terramate-wrapper.sh" "${destdir}/"
    ln -sf terramate-wrapper.sh "${destdir}/terramate"
  else
    ln -sf terramate-bin "${destdir}/terramate"
  fi

  terramate_version=$("${destdir}/terramate" --version)
  if [ "${terramate_version}" != "${version}" ] ; then
    echo >&2 "install: ERROR: terramate at ${destdir}/terramate is reporting a wrong version ${terramate_version}. Expected version is ${version}!"
    exit 1
  else
    echo >&2 "install: Version of '${destdir}/terramate' is '${version}'."
  fi

  default_terrmate_location=$(type -f -p terramate)
  if [ "${default_terrmate_location}" != "${destdir}/terramate" ] ; then
    echo >&2 "install: WARNING: Installation succeeded in ${destdir}/terramate but we are using ${default_terrmate_location} by default!"

    default_terramate_version=$(terramate --version)
    if [ "${default_terramate_version}" != "${version}" ] ; then
      echo >&2 "install: WARNING: terramate at ${default_terrmate_location} is using a different version ${default_terramate_version}. Expected version is '${version}'!"
    else
      echo >&2 "install: Version of (first in path) 'terramate' is '${version}'."
    fi
    exit 0
  fi
}

## main script

install
