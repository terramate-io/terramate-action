#!/bin/bash

set -eu

## GHA inputs

input_use_wrapper=${TMA_INPUT_USE_WRAPPER-true}
input_tm_version=${TMA_INPUT_VERSION-}
input_bindir=${TMA_INPUT_BINDIR-/usr/local/bin}

## GHA context

context_github_action_path=${GITHUB_ACTION_PATH-}

## functions

get_latest_version() {
  echo >&2 "latest version: Getting latest Terramate release information from GitHub Releases"

  latest_url="https://api.github.com/repos/terramate-io/terramate/releases/latest"
  latest_json=$(curl -s "${latest_url}")
  tag_version=$(jq -r .tag_name <<<"${latest_json}")

  if [ -z "${tag_version}" ] || [ "${tag_version}" == "null" ] ; then
    echo >&2 "latest version: Error extracting version from latest Terramate release on GitHub!"
    exit 1
  fi

  echo >&2 "latest version: Using latest version ${tag_version#v}!"

  echo "${tag_version#v}"
}

get_asdf_version() {
  if [ "${input_tm_version}" == "latest" ] ; then
    return
  fi

  asdf_config_file=".tool-versions"
  if [ ! -r "${asdf_config_file}" ] ; then
    echo >&2 "asdf integration: Skipping. No config file found at ${asdf_config_file}!"
    return
  fi

  echo >&2 "asdf integration: Getting desired Terramate Version from asdf config at ${asdf_config_file}!"

  asdf_version=$(awk '$1 == "terramate" {print $2}' "${asdf_config_file}")

  if [ -z "${asdf_version}" ] ; then
    echo >&2 "asdf integration: Skipping. No Terramate config found in asdf file ${asdf_config_file}!"
  else
    echo >&2 "asdf integration: Using asdf version ${asdf_version}!"
    echo "${asdf_version}"
  fi
}

get_version() {
  if [ "${input_tm_version}" == "latest" ] ; then
    get_latest_version
    return
  fi

  if [ -n "${input_tm_version}" ] ; then
    echo >&2 "input: Using user provided version ${input_tm_version}!"
    echo "${input_tm_version}"
    return
  fi

  asdf_version=$(get_asdf_version)
  if [ -n "${asdf_version}" ] ; then
    echo "${asdf_version}"
    return
  fi

  get_latest_version
}

## main install function

install() {
  destdir="${input_bindir}"

  version=$(get_version)
  echo >&2 "install: Downloading Terramate v${version}"

  tmpdir=$(mktemp -d)
  echo >&2 "install: Created tmp directory at ${tmpdir}"

  url="https://github.com/terramate-io/terramate/releases/download/v${version}/terramate_${version}_linux_x86_64.tar.gz"

  status=$(curl -w "%{http_code}" -o "${tmpdir}/terramate.tar.gz" -L "${url}")
  if [ "${status}" != "200" ] ; then
    echo >&2 "install: Error downloading release. Expected HTTP status 200 and got ${status}."
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
